targetScope = 'subscription'

@description('Location for operations resources.')
param location string

@description('Retention period in days for Log Analytics log data.')
@minValue(30)
@maxValue(730)
param logRetentionDays int = 90

@description('Name of the resource group for operations resources.')
param resourceGroupName string = 'rg-operations'

@description('Tags applied to operations resources.')
param tags object = {
  env: 'platform'
  workload: 'operations'
}

resource operationsRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module logAnalytics 'modules/operations/logAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: operationsRg
  params: {
    location: location
    retentionInDays: logRetentionDays
    tags: tags
  }
}

output operationsResourceGroupName string = operationsRg.name
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output logAnalyticsWorkspaceName string = logAnalytics.outputs.workspaceName
