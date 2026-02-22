targetScope = 'tenant'

@description('Management group ID to scope the policy assignment to.')
param managementGroupId string

@description('Location for the policy assignment resource.')
param location string

@description('Name of the policy assignment.')
param policyAssignmentName string

@description('Resource ID of the policy definition or initiative to assign.')
param policyDefinitionId string

// AVM wrapper for a single policy assignment. Use baselinePolicies.bicep for bulk assignments
// driven by baseline.json; use this module when you need AVM-managed lifecycle (DINE, remediation tasks, etc.).
module policyAssignment 'br/public:avm/ptn/authorization/policy-assignment:0.5.1' = {
  name: 'policyAssignmentDeployment'
  scope: managementGroup(managementGroupId)
  params: {
    name: policyAssignmentName
    policyDefinitionId: policyDefinitionId
    location: location
    metadata: {
      assignedBy: 'Bicep'
    }
  }
}
