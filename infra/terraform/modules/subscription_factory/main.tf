variable "platform_config_path" {
  type        = string
  description = "Path to platform.yaml manifest"
}

locals {
  platform = yamldecode(file(var.platform_config_path))
}

# TODO: Use subscription creation APIs (deploymentStacks/tenant deployments)
# to create subscriptions under the right management groups.

output "subscriptions" {
  description = "Subscriptions parsed from the manifest"
  value       = lookup(local.platform, "subscriptions", [])
}
