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
  scope: tenant()
  params: {
    platformConfigPath: platformConfigPath
  }
}

@description('Deploys Hub Networking resources.')
module hub '1-hub.bicep' = if (deploy.enableHub) {
  name: 'subscriptionFactory'
  scope: subscription()
  params: {
    platformConfigPath: platformConfigPath
  }
}

module spoke '2-spoke.bicep' = if (deploy.enableSpoke) {
  name: 'baselinePolicies'
  scope: subscription()
  params: {
    platformConfigPath: platformConfigPath
  }
}

module identity '3-identity.bicep' = if (deploy.enableIdentity) {
  name: 'centralDiagnostics'
  scope: subscription()
  params: {
    location: location
  }
}

module operations '4-operations.bicep' = if (deploy.enableOperations) {
  name: 'centralDiagnostics'
  scope: subscription()
  params: {
    location: location
  }
}

module sharedServices '5-sharedServices.bicep' = if (deploy.enableSharedServices) {
  name: 'centralDiagnostics'
  scope: subscription()
  params: {
    location: location
  }
}

module diagnostics '6-diagnostics.bicep' = if (deploy.enableDiagnostics) {
  name: 'centralDiagnostics'
  scope: subscription()
  params: {
    location: location
  }
}
