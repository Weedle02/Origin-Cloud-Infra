targetScope = 'tenant'

@description('Platform configuration manifest loaded from platform.yaml.')
param platformConfig object

@description('Location used for policy assignment metadata when required.')
param location string

@description('Policy assignment manifest loaded from baseline.json.')
param policyAssignments object = {}

var rootManagementGroupId = platformConfig.rootManagementGroupId
var managementGroups = platformConfig.managementGroups
var subscriptions = platformConfig.subscriptions ?? []
var policyAssignmentList = policyAssignments.policyAssignments ?? []

// Root management group is treated as existing; children are created/updated based on the manifest
resource rootManagementGroup 'Microsoft.Management/managementGroups@2020-05-01' existing = {
  name: rootManagementGroupId
}

resource childManagementGroups 'Microsoft.Management/managementGroups@2020-05-01' = [for group in managementGroups: {
  name: group.name
  properties: {
    displayName: group.displayName
    details: {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/${group.parent ?? rootManagementGroupId}'
      }
    }
  }
  dependsOn: [
    rootManagementGroup
  ]
}]

// Create subscriptions where billing scope is supplied.
var subscriptionsToCreate = [for sub in subscriptions: if (contains(sub, 'billingScope')) sub]

resource subscriptionAliases 'Microsoft.Subscription/aliases@2020-09-01' = [for sub in subscriptionsToCreate: {
  name: sub.alias
  properties: {
    displayName: sub.displayName
    workload: sub.workload ?? 'Production'
    billingScope: sub.billingScope
  }
}]

// Associate newly created subscriptions to the target management group.
resource createdSubscriptionAssociations 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = [for (sub, i) in subscriptionsToCreate: {
  name: subscriptionAliases[i].properties.subscriptionId
  scope: managementGroup(sub.managementGroup ?? rootManagementGroupId)
  dependsOn: [
    subscriptionAliases[i]
    childManagementGroups
  ]
}]

// Associate existing subscriptions (requires subscriptionId in the manifest).
var subscriptionsToAssociate = [for sub in subscriptions: if (contains(sub, 'subscriptionId')) sub]

resource existingSubscriptionAssociations 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = [for sub in subscriptionsToAssociate: {
  name: sub.subscriptionId
  scope: managementGroup(sub.managementGroup ?? rootManagementGroupId)
  dependsOn: [
    childManagementGroups
  ]
}]

// Baseline policy assignments at the root management group.
module baselinePolicies 'modules/policies/baselinePolicies.bicep' = if (length(policyAssignmentList) > 0) {
  name: 'baselinePolicies'
  scope: tenant()
  params: {
    rootManagementGroupId: rootManagementGroupId
    location: location
    policyAssignments: policyAssignments
  }
  dependsOn: [
    childManagementGroups
  ]
}

output createdManagementGroups array = managementGroups
output rootId string = rootManagementGroupId
