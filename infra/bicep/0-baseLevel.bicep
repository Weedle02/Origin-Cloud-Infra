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
// filter() produces a typed non-null array; the [for…if] pattern emits (T|null)[] which causes
// type errors on subsequent property accesses such as sub.alias.
var subscriptionsToCreate = filter(subscriptions, sub => contains(sub, 'billingScope'))

// API 2021-10-01 introduced additionalProperties.managementGroupId, so the subscription is
// placed in the target management group at creation time. This eliminates the need for a
// separate Microsoft.Management/managementGroups/subscriptions association step (whose
// 'name' property would require subscriptionAliases[i].properties.subscriptionId — a runtime
// value that ARM cannot resolve at the start of deployment).
resource subscriptionAliases 'Microsoft.Subscription/aliases@2021-10-01' = [for sub in subscriptionsToCreate: {
  name: sub.alias
  properties: {
    displayName: sub.displayName
    workload: sub.workload ?? 'Production'
    billingScope: sub.billingScope
    additionalProperties: {
      managementGroupId: '/providers/Microsoft.Management/managementGroups/${string(sub.managementGroup ?? rootManagementGroupId)}'
    }
  }
  dependsOn: [childManagementGroups]
}]

// Associate existing subscriptions (requires subscriptionId in the manifest).
var subscriptionsToAssociate = filter(subscriptions, sub => contains(sub, 'subscriptionId'))

// Microsoft.Management/managementGroups/subscriptions is tenant-scoped; no scope: property is
// allowed. The name must encode both segments as '{managementGroupId}/{subscriptionId}'.
// string() casts are required because filter() types each element as 'object'.
resource existingSubscriptionAssociations 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = [for sub in subscriptionsToAssociate: {
  name: '${string(sub.managementGroup ?? rootManagementGroupId)}/${string(sub.subscriptionId)}'
  dependsOn: [
    childManagementGroups
  ]
}]

// Baseline policy assignments scoped to the root management group.
// The module's targetScope is 'managementGroup', so scope: here drives which group it targets.
module baselinePolicies 'modules/policies/baselinePolicies.bicep' = if (length(policyAssignmentList) > 0) {
  name: 'baselinePolicies'
  scope: managementGroup(rootManagementGroupId)
  params: {
    location: location
    policyAssignments: policyAssignments
  }
  dependsOn: [
    childManagementGroups
  ]
}

output createdManagementGroups array = managementGroups
output rootId string = rootManagementGroupId
