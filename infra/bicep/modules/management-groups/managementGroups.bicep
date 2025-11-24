// Scaffold module: creates management group hierarchy based on platform.yaml
@description('Path to platform.yaml manifest')
param platformConfigPath string

// TODO: Replace with logic to parse manifest and create management groups.
// For now, we expose outputs that future modules can use.

output description string = 'Create management group hierarchy from ' + platformConfigPath
