@description('Location for spoke networking resources.')
param location string

@description('Address space for the spoke virtual network.')
param addressSpace string

@description('Resource ID of the hub VNet to peer with. Leave empty to skip peering.')
param hubVnetId string = ''

@description('Tags for spoke networking resources.')
param tags object

var subnets = [
  {
    name: 'app-subnet'
    prefix: cidrSubnet(addressSpace, 24, 0)
  }
  {
    name: 'data-subnet'
    prefix: cidrSubnet(addressSpace, 24, 1)
  }
  {
    name: 'AzureBastionSubnet'
    prefix: cidrSubnet(addressSpace, 27, 8)
  }
]

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-spoke'
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

// Peer spoke -> hub. forwardedTraffic is enabled so the Azure Firewall in hub can inspect spoke egress.
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = if (!empty(hubVnetId)) {
  parent: spokeVnet
  name: 'spoke-to-hub'
  properties: {
    remoteVirtualNetwork: { id: hubVnetId }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

output spokeVnetId string = spokeVnet.id
output spokeVnetName string = spokeVnet.name
