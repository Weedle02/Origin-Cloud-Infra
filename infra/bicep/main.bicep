// Entry point for Azure Platform Starter Kit (Bicep)
// This file wires management groups, subscriptions, policies, and diagnostics.

@description('Path to the platform configuration manifest (tenant, management groups, subscriptions).')
param platformConfigPath string = 'platform/config/platform.yaml'

@description('Location used for shared resources like Log Analytics.')
param location string = 'eastus'

@description('Toggle to enable diagnostic resources (Log Analytics, storage, Sentinel).')
param enableDiagnostics bool = true

// The following modules are scaffolds. Populate them with real resources
// before deploying to Azure.
module managementGroups 'modules/management-groups/managementGroups.bicep' = {
  name: 'managementGroups'
  params: {
    platformConfigPath: platformConfigPath
  }
}

module subscriptionFactory 'modules/subscription-factory/subscriptionFactory.bicep' = {
  name: 'subscriptionFactory'
  params: {
    platformConfigPath: platformConfigPath
  }
  dependsOn: [managementGroups]
}

module baselinePolicies 'modules/policies/baselinePolicies.bicep' = {
  name: 'baselinePolicies'
  params: {
    platformConfigPath: platformConfigPath
  }
  dependsOn: [managementGroups, subscriptionFactory]
}

module diagnostics 'modules/diagnostics/diagnostics.bicep' = if (enableDiagnostics) {
  name: 'centralDiagnostics'
  params: {
    location: location
  }
  dependsOn: [managementGroups, subscriptionFactory]
}
