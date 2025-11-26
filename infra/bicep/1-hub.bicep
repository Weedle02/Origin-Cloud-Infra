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

var subnets = [
  {
    name: 'AzureFirewallSubnet'
    prefix: '10.0.0.0/26'
  }
  {
    name: 'GatewaySubnet'
    prefix: '10.0.0.64/27'
  }
  {
    name: 'shared-services'
    prefix: '10.0.1.0/24'
  }
]

resource hubRg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-hub'
  location: hubRg.location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [addressSpace]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.prefix
      }
    }]
  }
}

output hubResourceGroupName string = hubRg.name
output hubVnetId string = hubVnet.id
