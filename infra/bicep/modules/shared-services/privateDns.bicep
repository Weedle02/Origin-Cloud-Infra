@description('Resource ID of the hub VNet to link DNS zones to. Leave empty to skip VNet links.')
param hubVnetId string = ''

@description('Tags for DNS zone resources.')
param tags object

// Core private DNS zones covering the most common PaaS private endpoint scenarios.
// Extend this list as workloads are onboarded.
var dnsZoneNames = [
  'privatelink.blob.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.table.core.windows.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.database.windows.net'
  'privatelink${environment().suffixes.sqlServerHostname}'
]

resource dnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in dnsZoneNames: {
  name: zone
  location: 'global'
  tags: tags
}]

// Link each zone to the hub VNet so all VMs and services in hub/spoke can resolve private endpoints.
resource dnsZoneVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (zone, i) in dnsZoneNames: if (!empty(hubVnetId)) {
  parent: dnsZones[i]
  name: 'link-to-hub'
  location: 'global'
  properties: {
    virtualNetwork: { id: hubVnetId }
    registrationEnabled: false
  }
}]

output dnsZoneNames array = dnsZoneNames
output dnsZoneIds array = [for (zone, i) in dnsZoneNames: dnsZones[i].id]
