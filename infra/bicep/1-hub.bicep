targetScope = 'subscription'

@description('Primary location for hub networking resources.')
param location string

@description('Address space allocated to the hub virtual network.')
param addressSpace string = '10.0.0.0/16'

@description('Name of the resource group that will contain the hub assets.')
param resourceGroupName string = 'rg-hub-network'

@description('Tags applied to hub resources for governance and chargeback.')
param tags object = {
  env: 'platform'
  workload: 'hub'
}

resource hubRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module hubNetwork 'modules/network/hubNetwork.bicep' = {
  name: 'hubNetwork'
  scope: hubRg
  params: {
    location: location
    addressSpace: addressSpace
    tags: tags
  }
}

output hubResourceGroupName string = hubRg.name
output hubVnetId string = hubNetwork.outputs.hubVnetId
