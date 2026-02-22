output "management_groups" {
  description = "Management group entries parsed from the manifest"
  value       = lookup(local.platform, "managementGroups", [])
}

output "management_group_ids" {
  description = "Map of management group name to resource ID"
  value       = { for name, group in azurerm_management_group.groups : name => group.id }
}

output "root_management_group_id" {
  description = "Resource ID of the root management group"
  value       = data.azurerm_management_group.root.id
}
