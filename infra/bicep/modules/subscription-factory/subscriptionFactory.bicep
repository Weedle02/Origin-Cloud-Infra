// Scaffold module: provisions subscriptions and links them to management groups.
@description('Path to platform.yaml manifest')
param platformConfigPath string

// TODO: Implement subscription creation using deploymentStacks/tenant deployments when GA.
// This placeholder signals intended behavior.
output description string = 'Provision subscriptions defined in ' + platformConfigPath
