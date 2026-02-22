variable "platform_config_path" {
  type        = string
  description = "Path to platform.yaml manifest"
}

variable "root_management_group_id" {
  type        = string
  description = "Root management group ID from the platform manifest"
}

variable "management_group_ids" {
  type        = map(string)
  description = "Map of management group names to IDs"
}

variable "billing_scope_id" {
  type        = string
  description = "EA enrollment or MCA billing scope ID required to vend new subscriptions. Leave null to skip subscription creation and only manage associations for existing subscriptions."
  default     = null
  sensitive   = true
}
