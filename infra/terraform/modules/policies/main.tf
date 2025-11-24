variable "platform_config_path" {
  type        = string
  description = "Path to platform.yaml manifest"
}

locals {
  platform = yamldecode(file(var.platform_config_path))
}

# TODO: Define azurerm_policy_definition and azurerm_policy_assignment resources
# to enforce allowed SKUs, locations, required tags, diagnostics, and backup policies.

output "policy_scope" {
  description = "Root management group for policy assignments"
  value       = lookup(local.platform, "rootManagementGroupId", null)
}
