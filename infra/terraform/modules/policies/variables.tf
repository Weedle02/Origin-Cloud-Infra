variable "platform_config_path" {
  type        = string
  description = "Path to platform.yaml manifest"
}

variable "policy_assignments_path" {
  type        = string
  description = "Path to policy assignment JSON manifest"
}

variable "root_management_group_id" {
  type        = string
  description = "Root management group ID where baseline policies are assigned"
}
