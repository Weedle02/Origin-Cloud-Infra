using 'main.bicep'

param deploy object = {
  enableBaseLevel: true
  enableHub: true
  enableSpoke: true
  enableIdentity: true
  enableOperations: true
  enableSharedServices: true
  enableDiagnostics: true
}

param platformConfigPath = 'platform/config/platform.yaml'

param location = 'eastus'
