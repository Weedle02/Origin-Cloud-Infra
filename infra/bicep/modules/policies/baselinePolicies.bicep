// Scaffold module: attaches policy assignments for allowed SKUs, locations, tags, diagnostics, and backup.
@description('Path to platform.yaml manifest')
param platformConfigPath string

// TODO: Add policy definitions/assignments and parameter files.
output description string = 'Assign baseline policies informed by ' + platformConfigPath
