targetScope = 'tenant'

@description('Root management group name where baseline policies are assigned.')
param rootManagementGroupId string

@description('Location used for policy assignment metadata when required.')
param location string

@description('Policy assignment manifest loaded from baseline.json.')
param policyAssignments object

var policyAssignmentList = policyAssignments.policyAssignments ?? []

resource baselinePolicyAssignments 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for assignment in policyAssignmentList: {
  name: assignment.name
  scope: managementGroup(rootManagementGroupId)
  location: assignment.location ?? location
  properties: {
    displayName: assignment.displayName ?? assignment.name
    policyDefinitionId: assignment.policyDefinitionId
    description: assignment.description ?? null
    metadata: assignment.metadata ?? {
      assignedBy: 'Bicep'
    }
    parameters: assignment.params ?? {}
    enforcementMode: assignment.enforcementMode ?? 'Default'
  }
}]
