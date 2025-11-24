// Scaffold module: creates central diagnostics (Log Analytics, storage, Sentinel, budgets)
@description('Primary location for diagnostics resources')
param location string

// TODO: Implement workspace, storage, Sentinel onboarding, and budgets.
output description string = 'Create diagnostics resources in ' + location
