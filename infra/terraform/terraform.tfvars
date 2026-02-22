# Platform manifest paths
platform_config_path    = "platform/config/platform.yaml"
policy_assignments_path = "policies/assignments/baseline.json"

# Region
location = "eastus"

# Diagnostics
enable_diagnostics      = true
enable_sentinel         = false
# diagnostics_name_suffix must be set to a unique alphanumeric string to avoid
# Azure Storage Account name collisions across environments/tenants.
# diagnostics_name_suffix = ""

# Subscription vending — set to your EA enrollment or MCA billing scope to enable
# creating new subscriptions from the platform manifest.
# billing_scope_id = null
