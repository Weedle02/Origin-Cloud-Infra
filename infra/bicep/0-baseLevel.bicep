targetScope = 'tenant'

@description('Path to the platform configuration manifest (tenant, management groups, subscriptions).')
param platformConfigPath string

var platform = loadYamlContent(platformConfigPath)
var rootManagementGroupId = platform.rootManagementGroupId
var managementGroups = platform.managementGroups

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

output createdManagementGroups array = managementGroups
output rootId string = rootManagementGroupId
