output "log_analytics_workspace_id" {
  description = "Resource ID of the central Log Analytics workspace"
  value       = var.enabled ? azurerm_log_analytics_workspace.platform[0].id : null
}

output "log_analytics_workspace_name" {
  description = "Name of the central Log Analytics workspace"
  value       = var.enabled ? azurerm_log_analytics_workspace.platform[0].name : null
}

output "log_analytics_workspace_key" {
  description = "Primary shared key for the Log Analytics workspace"
  value       = var.enabled ? azurerm_log_analytics_workspace.platform[0].primary_shared_key : null
  sensitive   = true
}

output "storage_account_id" {
  description = "Resource ID of the diagnostics archive storage account"
  value       = var.enabled ? azurerm_storage_account.diagnostics[0].id : null
}

output "resource_group_name" {
  description = "Resource group containing shared diagnostics resources"
  value       = var.enabled ? azurerm_resource_group.diagnostics[0].name : null
}
