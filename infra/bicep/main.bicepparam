using 'main.bicep'

// ── Platform manifest & policies ──────────────────────────────────────────────
// These files are the single source of truth for tenant topology and governance.
// Edit them directly rather than overriding values here.

param platformConfig = loadYamlContent('../../platform/config/platform.yaml')

param policyAssignments = loadJsonContent('../../policies/assignments/baseline.json')

// ── Deployment toggles ─────────────────────────────────────────────────────────
// Set any flag to false to skip that layer without touching the others.
// Typical order for a greenfield deployment:
//   baseLevel → hub → spoke → identity → operations → sharedServices → diagnostics

param deploy = {
  enableBaseLevel: true
  enableHub: true
  enableSpoke: true
  enableIdentity: true
  enableOperations: true
  enableSharedServices: true
  enableDiagnostics: true
}

// ── Location ───────────────────────────────────────────────────────────────────

param location = 'eastus'

// ── Networking ────────────────────────────────────────────────────────────────
// Allocate non-overlapping RFC-1918 ranges for hub and spoke.
// Subnets within each VNet are auto-derived via cidrSubnet(), so only the
// parent /16 needs to be set here.

param hubAddressSpace = '10.0.0.0/16'
param spokeAddressSpace = '10.1.0.0/16'

// ── Operations ────────────────────────────────────────────────────────────────

param logRetentionDays = 90

// ── Governance / tagging ──────────────────────────────────────────────────────
// Merged into every resource group and resource alongside layer-specific tags
// (env, workload). Add costCenter, owner, or ticket fields here to satisfy
// your organisation's tagging policy. Values here override layer defaults when
// keys collide.

param commonTags = {
  managedBy: 'bicep'
  environment: 'platform'
}
