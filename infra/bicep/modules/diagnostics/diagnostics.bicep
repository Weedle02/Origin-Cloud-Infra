@description('Location for diagnostics resources.')
param location string

@description('Name for the diagnostics storage account. Must be globally unique, 3-24 lowercase alphanumeric characters.')
param storageAccountName string

@description('Tags for diagnostics resources.')
param tags object = {}

// Storage account used as long-term archival destination for platform diagnostic logs.
// Set to Cool tier since logs are written frequently but rarely read.
resource diagnosticsStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
  }
}

output storageAccountId string = diagnosticsStorage.id
output storageAccountName string = diagnosticsStorage.name
