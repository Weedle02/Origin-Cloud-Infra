targetScope = 'subscription'

@description('Location for identity resources.')
param location string

@description('Name of the resource group for identity resources.')
param resourceGroupName string = 'rg-identity'

@description('Tags applied to identity resources.')
param tags object = {
  env: 'platform'
  workload: 'identity'
}

resource identityRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module platformIdentity 'modules/identity/platformIdentity.bicep' = {
  name: 'platformIdentity'
  scope: identityRg
  params: {
    location: location
    tags: tags
  }
}

output identityResourceGroupName string = identityRg.name
output platformIdentityId string = platformIdentity.outputs.identityId
output platformIdentityPrincipalId string = platformIdentity.outputs.principalId
output platformIdentityClientId string = platformIdentity.outputs.clientId
