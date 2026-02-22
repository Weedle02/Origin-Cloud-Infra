@description('Location for hub networking resources.')
param location string

@description('Address space for the hub virtual network.')
param addressSpace string

@description('Tags for hub networking resources.')
param tags object

var subnets = [
  {
    name: 'AzureFirewallSubnet'
    prefix: cidrSubnet(addressSpace, 26, 0)
  }
  {
    name: 'GatewaySubnet'
    prefix: cidrSubnet(addressSpace, 27, 2)
  }
  {
    name: 'shared-services'
    prefix: cidrSubnet(addressSpace, 24, 1)
  }
]

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-hub'
  location: location
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

output hubVnetId string = hubVnet.id
output hubVnetName string = hubVnet.name
