targetScope = 'tenant'

@description('Platform configuration manifest loaded from platform.yaml.')
param platformConfig object

var rootManagementGroupId = platformConfig.rootManagementGroupId
var managementGroups = platformConfig.managementGroups

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
