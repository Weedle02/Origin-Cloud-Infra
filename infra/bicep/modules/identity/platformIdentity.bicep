@description('Location for identity resources.')
param location string

@description('Tags for identity resources.')
param tags object

// Single user-assigned managed identity used by platform automation (pipelines, scripts, etc.)
resource platformIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-platform'
  location: location
  tags: tags
}

output identityId string = platformIdentity.id
output principalId string = platformIdentity.properties.principalId
output clientId string = platformIdentity.properties.clientId
