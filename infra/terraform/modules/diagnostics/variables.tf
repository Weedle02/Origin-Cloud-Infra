variable "location" {
  type        = string
  description = "Primary location for diagnostics resources"
}

variable "enabled" {
  type        = bool
  description = "Whether to deploy diagnostics resources"
  default     = true
}

variable "retention_days" {
  type        = number
  description = "Log Analytics Workspace data retention in days"
  default     = 90
}

variable "enable_sentinel" {
  type        = bool
  description = "Whether to onboard Microsoft Sentinel on the Log Analytics Workspace"
  default     = false
}

variable "name_suffix" {
  type        = string
  description = "Short alphanumeric suffix appended to globally-unique resource names (e.g. storage accounts). Must be lowercase and contain no hyphens."
  default     = ""
}
