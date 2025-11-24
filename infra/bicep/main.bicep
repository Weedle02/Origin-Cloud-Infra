targetScope = 'subscription'

//Parameters

@description('Path to the platform configuration manifest (tenant, management groups, subscriptions).')
param platformConfigPath string 

@description('Location used for shared resources like Log Analytics.')
param location string 

@description('Toggle to enable or disable deployment of various components.')
param deploy object 

@description('Deplys management groups and Policies before subscriptions are created.')
module baseLevel 'modules/management-groups/managementGroups.bicep' = if (deploy.enableBaseLevel) {
  name: 'managementGroups'
  params: {
    platformConfigPath: platformConfigPath
  }
}

@description('Deploys Hub Networking resources.')
module hub '1-hub.bicep' = if (deploy.enableHub) {
  name: 'subscriptionFactory'
  params: {
    platformConfigPath: platformConfigPath
  }
  dependsOn: [managementGroups]
}

module spoke '2-spoke.bicep' = if (deploy.enableSpoke) {
  name: 'baselinePolicies'
  params: {
    platformConfigPath: platformConfigPath
  }
  dependsOn: [managementGroups, subscriptionFactory]
}

module identity '3-identity.bicep' = if (deploy.enableIdentity) {
  name: 'centralDiagnostics'
  params: {
    location: location
  }
  dependsOn: [managementGroups, subscriptionFactory]
}

module operations '4-operations.bicep' = if (deploy.enableOperations) {
  name: 'centralDiagnostics'
  params: {
    location: location
  }
  dependsOn: [managementGroups, subscriptionFactory]
}

module sharedServices '5-sharedServices.bicep' = if (deploy.enableSharedServices) {
  name: 'centralDiagnostics'
  params: {
    location: location
  }
  dependsOn: [managementGroups, subscriptionFactory]
}

module diagnostics '6-diagnostics.bicep' = if (deploy.enableDiagnostics) {
  name: 'centralDiagnostics'
  params: {
    location: location
  }
  dependsOn: [managementGroups, subscriptionFactory]
}
