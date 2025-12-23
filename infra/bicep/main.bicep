targetScope = 'subscription'

//Parameters

@description('Platform configuration manifest (tenant, management groups, subscriptions).')
param platformConfig object

@description('Location used for shared resources like Log Analytics and hub networking.')
param location string

@description('Toggle to enable or disable deployment of various components.')
param deploy object

@description('Creates the base-level management group hierarchy from the platform manifest.')
module baseLevel '0-baseLevel.bicep' = if (deploy.enableBaseLevel) {
  name: 'baseLevel'
  scope: tenant()
  params: {
    platformConfig: platformConfig
  }
}

@description('Deploys Hub Networking resources into the current subscription.')
module hub '1-hub.bicep' = if (deploy.enableHub) {
  name: 'hub'
  scope: subscription()
  params: {
    location: location
  }
}

module spoke '2-spoke.bicep' = if (deploy.enableSpoke) {
  name: 'spoke'
  scope: subscription()
  params: {
    platformConfig: platformConfig
  }
}

module identity '3-identity.bicep' = if (deploy.enableIdentity) {
  name: 'identity'
  scope: subscription()
  params: {
    location: location
  }
}

module operations '4-operations.bicep' = if (deploy.enableOperations) {
  name: 'operations'
  scope: subscription()
  params: {
    location: location
  }
}

module sharedServices '5-sharedServices.bicep' = if (deploy.enableSharedServices) {
  name: 'sharedServices'
  scope: subscription()
  params: {
    location: location
  }
}

module diagnostics '6-diagnostics.bicep' = if (deploy.enableDiagnostics) {
  name: 'diagnostics'
  scope: subscription()
  params: {
    location: location
  }
}
