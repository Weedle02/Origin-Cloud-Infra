targetScope = 'subscription'

@description('Platform configuration manifest loaded from platform.yaml.')
param platformConfig object

@description('Primary location for spoke networking resources.')
param location string

@description('Resource ID of the hub VNet to peer with. Leave empty to skip peering.')
param hubVnetId string = ''

@description('Address space for the spoke virtual network.')
param addressSpace string = '10.1.0.0/16'

@description('Name of the resource group for spoke networking resources.')
param resourceGroupName string = 'rg-spoke-network'

@description('Tags applied to spoke resources.')
param tags object = {
  env: 'landing-zone'
  workload: 'spoke'
}

resource spokeRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: union(tags, { tenantId: platformConfig.tenantId })
}

module spokeNetwork 'modules/network/spokeNetwork.bicep' = {
  name: 'spokeNetwork'
  scope: spokeRg
  params: {
    location: location
    addressSpace: addressSpace
    hubVnetId: hubVnetId
    tags: tags
  }
}

output spokeResourceGroupName string = spokeRg.name
output spokeVnetId string = spokeNetwork.outputs.spokeVnetId
