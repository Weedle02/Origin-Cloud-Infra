targetScope = 'subscription'

@description('Location for diagnostics resources.')
param location string

@description('Resource ID of the Log Analytics Workspace. Passed through to outputs for use by downstream tooling or policy. Leave empty when operations is disabled.')
param logAnalyticsWorkspaceId string = ''

@description('Name of the resource group for diagnostics resources.')
param resourceGroupName string = 'rg-diagnostics'

@description('Tags applied to diagnostics resources.')
param tags object = {
  env: 'platform'
  workload: 'diagnostics'
}

resource diagnosticsRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Storage account name: 'stdiag' prefix + 13-char uniqueString = 19 chars, within the 24-char limit.
var storageAccountName = 'stdiag${uniqueString(subscription().subscriptionId)}'

module diagnosticsInfra 'modules/diagnostics/diagnostics.bicep' = {
  name: 'diagnosticsInfra'
  scope: diagnosticsRg
  params: {
    location: location
    storageAccountName: storageAccountName
    tags: tags
  }
}

output diagnosticsResourceGroupName string = diagnosticsRg.name
output diagnosticsStorageAccountId string = diagnosticsInfra.outputs.storageAccountId
// Surface the workspace ID so downstream scripts and policy assignments can reference it.
output logAnalyticsWorkspaceId string = logAnalyticsWorkspaceId
