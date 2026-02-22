output "management_group_ids" {
  description = "Map of management group name to resource ID"
  value       = module.management_groups.management_group_ids
}

output "root_management_group_id" {
  description = "Resource ID of the root management group"
  value       = module.management_groups.root_management_group_id
}

output "subscriptions" {
  description = "Subscription entries parsed from the platform manifest"
  value       = module.subscription_factory.subscriptions
}

output "new_subscription_ids" {
  description = "Map of newly vended subscription aliases to their subscription IDs"
  value       = module.subscription_factory.new_subscription_ids
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the central Log Analytics workspace"
  value       = module.diagnostics.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the central Log Analytics workspace"
  value       = module.diagnostics.log_analytics_workspace_name
}

output "diagnostics_resource_group" {
  description = "Resource group containing shared diagnostics resources"
  value       = module.diagnostics.resource_group_name
}
