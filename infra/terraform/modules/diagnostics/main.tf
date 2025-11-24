variable "location" {
  type        = string
  description = "Primary location for diagnostics"
}

variable "enabled" {
  type        = bool
  description = "Whether to deploy diagnostics"
  default     = true
}

# TODO: Add Log Analytics, Storage, Sentinel, budgets, and cost alerts.

locals {
  workspace_name = "platform-law"
}

output "log_analytics_workspace_name" {
  description = "Name placeholder for the central Log Analytics workspace"
  value       = var.enabled ? local.workspace_name : null
}
