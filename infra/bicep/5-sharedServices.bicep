targetScope = 'subscription'

@description('Location for shared services resources.')
param location string

@description('Resource ID of the hub VNet to link private DNS zones to. Leave empty to skip VNet links.')
param hubVnetId string = ''

@description('Name of the resource group for shared services.')
param resourceGroupName string = 'rg-shared-services'

@description('Tags applied to shared services resources.')
param tags object = {
  env: 'platform'
  workload: 'shared-services'
}

resource sharedServicesRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module privateDns 'modules/shared-services/privateDns.bicep' = {
  name: 'privateDns'
  scope: sharedServicesRg
  params: {
    hubVnetId: hubVnetId
    tags: tags
  }
}

output sharedServicesResourceGroupName string = sharedServicesRg.name
output privateDnsZoneIds array = privateDns.outputs.dnsZoneIds
