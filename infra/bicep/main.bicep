targetScope = 'subscription'

// ── Platform manifest & policies ──────────────────────────────────────────────

@description('Platform configuration manifest (tenant, management groups, subscriptions). Loaded from platform/config/platform.yaml.')
param platformConfig object

@description('Policy assignment manifest. Loaded from policies/assignments/baseline.json.')
param policyAssignments object

// ── Deployment toggles ─────────────────────────────────────────────────────────

@description('Feature flags that enable or disable each deployment layer independently.')
param deploy object

// ── Location ───────────────────────────────────────────────────────────────────

@description('Primary Azure region for all platform resources.')
param location string

// ── Networking ────────────────────────────────────────────────────────────────

@description('RFC-1918 address space for the hub virtual network. Subnets are derived automatically via cidrSubnet().')
param hubAddressSpace string = '10.0.0.0/16'

@description('RFC-1918 address space for the spoke virtual network. Must not overlap with hubAddressSpace.')
param spokeAddressSpace string = '10.1.0.0/16'

// ── Operations ────────────────────────────────────────────────────────────────

@description('Log Analytics data retention in days. Minimum 30, maximum 730.')
@minValue(30)
@maxValue(730)
param logRetentionDays int = 90

// ── Governance / tagging ──────────────────────────────────────────────────────

@description('Tags merged into every resource group and resource. Workload-specific tags (env, workload) are set per-layer; values in commonTags override them when keys collide.')
param commonTags object = {}

// ── Layer 0: Governance ────────────────────────────────────────────────────────

module baseLevel '0-baseLevel.bicep' = if (deploy.enableBaseLevel) {
  name: 'baseLevel'
  scope: tenant()
  params: {
    platformConfig: platformConfig
    location: location
    policyAssignments: policyAssignments
  }
}

// ── Layer 1: Hub networking ────────────────────────────────────────────────────

module hub '1-hub.bicep' = if (deploy.enableHub) {
  name: 'hub'
  scope: subscription()
  params: {
    location: location
    addressSpace: hubAddressSpace
    tags: union({ env: 'platform', workload: 'hub' }, commonTags)
  }
}

// ── Layer 2: Spoke networking ──────────────────────────────────────────────────

module spoke '2-spoke.bicep' = if (deploy.enableSpoke) {
  name: 'spoke'
  scope: subscription()
  params: {
    platformConfig: platformConfig
    location: location
    addressSpace: spokeAddressSpace
    hubVnetId: hub.?outputs.hubVnetId ?? ''
    tags: union({ env: 'landing-zone', workload: 'spoke' }, commonTags)
  }
}

// ── Layer 3: Identity ──────────────────────────────────────────────────────────

module identity '3-identity.bicep' = if (deploy.enableIdentity) {
  name: 'identity'
  scope: subscription()
  params: {
    location: location
    tags: union({ env: 'platform', workload: 'identity' }, commonTags)
  }
}

// ── Layer 4: Operations / monitoring ──────────────────────────────────────────

module operations '4-operations.bicep' = if (deploy.enableOperations) {
  name: 'operations'
  scope: subscription()
  params: {
    location: location
    logRetentionDays: logRetentionDays
    tags: union({ env: 'platform', workload: 'operations' }, commonTags)
  }
}

// ── Layer 5: Shared services ───────────────────────────────────────────────────

module sharedServices '5-sharedServices.bicep' = if (deploy.enableSharedServices) {
  name: 'sharedServices'
  scope: subscription()
  params: {
    location: location
    hubVnetId: hub.?outputs.hubVnetId ?? ''
    tags: union({ env: 'platform', workload: 'shared-services' }, commonTags)
  }
}

// ── Layer 6: Diagnostics ───────────────────────────────────────────────────────

module diagnostics '6-diagnostics.bicep' = if (deploy.enableDiagnostics) {
  name: 'diagnostics'
  scope: subscription()
  params: {
    location: location
    logAnalyticsWorkspaceId: operations.?outputs.logAnalyticsWorkspaceId ?? ''
    tags: union({ env: 'platform', workload: 'diagnostics' }, commonTags)
  }
}
