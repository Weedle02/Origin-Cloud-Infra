variable "platform_config_path" {
  type        = string
  description = "Path to the platform configuration manifest"
  default     = "platform/config/platform.yaml"
}

variable "location" {
  type        = string
  description = "Primary Azure region for shared resources"
  default     = "eastus"
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to deploy shared diagnostic resources (Log Analytics, Storage)"
  default     = true
}

variable "enable_sentinel" {
  type        = bool
  description = "Whether to onboard Microsoft Sentinel on the platform Log Analytics workspace"
  default     = false
}

variable "diagnostics_name_suffix" {
  type        = string
  description = "Short alphanumeric suffix for globally-unique diagnostics resource names (e.g. storage accounts). Lowercase, no hyphens."
  default     = ""
}

variable "policy_assignments_path" {
  type        = string
  description = "Path to the policy assignment manifest JSON"
  default     = "policies/assignments/baseline.json"
}

variable "billing_scope_id" {
  type        = string
  description = "EA enrollment or MCA billing scope ID for vending new subscriptions from the platform manifest. Leave null to skip subscription creation."
  default     = null
  sensitive   = true
}
