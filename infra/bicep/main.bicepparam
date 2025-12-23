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

param platformConfig = loadYamlContent('../../platform/config/platform.yaml')

param location = 'eastus'

