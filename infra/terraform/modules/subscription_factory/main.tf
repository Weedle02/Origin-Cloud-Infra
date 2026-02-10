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

locals {
  platform = yamldecode(file(var.platform_config_path))
  subscriptions = try(local.platform.subscriptions, [])
  subscriptions_with_id = {
    for sub in local.subscriptions : sub.alias => sub
    if contains(keys(sub), "subscriptionId")
  }
}

resource "azurerm_management_group_subscription_association" "existing_subscriptions" {
  for_each = local.subscriptions_with_id

  subscription_id     = each.value.subscriptionId
  management_group_id = contains(keys(var.management_group_ids), try(each.value.managementGroup, "")) ? var.management_group_ids[each.value.managementGroup] : "/providers/Microsoft.Management/managementGroups/${var.root_management_group_id}"
}

output "subscriptions" {
  description = "Subscriptions parsed from the manifest"
  value       = lookup(local.platform, "subscriptions", [])
}
