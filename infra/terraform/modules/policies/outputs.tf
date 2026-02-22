output "policy_scope" {
  description = "Root management group used as policy assignment scope"
  value       = lookup(local.platform, "rootManagementGroupId", null)
}

output "policy_assignment_ids" {
  description = "Map of policy assignment name to resource ID"
  value       = { for k, v in azurerm_policy_assignment.baseline : k => v.id }
}
