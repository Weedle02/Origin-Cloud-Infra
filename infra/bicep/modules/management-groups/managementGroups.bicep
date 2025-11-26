targetScope = 'tenant'

param location string

param mainPolicyAssignmentName string

param policyDefinitionId string 

module policyAssignment 'br/public:avm/ptn/authorization/policy-assignment:0.5.1' = {
  name: 'policyAssignmentDeployment'
  scope: managementGroup('mainmanagementgroup')
  params: {
    name: mainPolicyAssignmentName
    policyDefinitionId: policyDefinitionId
    location: location
    metadata: {
      assignedBy: 'Bicep'
    }
  }
}
