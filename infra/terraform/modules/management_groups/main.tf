variable "platform_config_path" {
  type        = string
  description = "Path to platform.yaml manifest"
}

locals {
  platform = yamldecode(file(var.platform_config_path))
}

# TODO: Create management groups based on local.platform.managementGroups
# Example resource: azurerm_management_group

output "management_groups" {
  description = "Management group entries parsed from the manifest"
  value       = lookup(local.platform, "managementGroups", [])
}
