targetScope = 'managementGroup'

@description('Location used for policy assignment metadata when required.')
param location string

@description('Policy assignment manifest loaded from baseline.json.')
param policyAssignments object

var policyAssignmentList = policyAssignments.policyAssignments ?? []

// No scope: property needed — the management group is determined by the caller via
// scope: managementGroup(rootManagementGroupId) in the module invocation.
resource baselinePolicyAssignments 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for assignment in policyAssignmentList: {
  name: assignment.name
  location: assignment.location ?? location
  properties: {
    displayName: assignment.displayName ?? assignment.name
    policyDefinitionId: assignment.policyDefinitionId
    description: assignment.?description ?? ''
    metadata: assignment.metadata ?? {
      assignedBy: 'Bicep'
    }
    parameters: assignment.params ?? {}
    enforcementMode: assignment.enforcementMode ?? 'Default'
  }
}]
