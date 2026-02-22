variable "platform_config_path" {
  type        = string
  description = "Path to platform.yaml manifest"
}

variable "management_group_ids" {
  type        = map(string)
  description = "Map of management group names to IDs, used for scope resolution"
  default     = {}
}
