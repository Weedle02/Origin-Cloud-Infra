locals {
  platform      = yamldecode(file(var.platform_config_path))
  subscriptions = try(local.platform.subscriptions, [])

  # Subscriptions that already exist — associate them to their target management group.
  subscriptions_with_id = {
    for sub in local.subscriptions : sub.alias => sub
    if contains(keys(sub), "subscriptionId")
  }
  
  subscriptions_to_create = var.billing_scope_id != null ? {
    for sub in local.subscriptions : sub.alias => sub
    if !contains(keys(sub), "subscriptionId")
  } : {}
}

# Vend new subscriptions via EA enrollment or MCA billing scope.
resource "azurerm_subscription" "new" {
  for_each          = local.subscriptions_to_create
  subscription_name = try(each.value.displayName, each.key)
  alias             = each.key
  billing_scope_id  = var.billing_scope_id
}

# Associate pre-existing subscriptions to their target management group.
resource "azurerm_management_group_subscription_association" "existing" {
  for_each = local.subscriptions_with_id

  subscription_id = each.value.subscriptionId
  management_group_id = (
    contains(keys(var.management_group_ids), try(each.value.managementGroup, ""))
    ? var.management_group_ids[each.value.managementGroup]
    : "/providers/Microsoft.Management/managementGroups/${var.root_management_group_id}"
  )
}

# Associate newly vended subscriptions to their target management group.
resource "azurerm_management_group_subscription_association" "new" {
  for_each = local.subscriptions_to_create

  subscription_id = azurerm_subscription.new[each.key].subscription_id
  management_group_id = (
    contains(keys(var.management_group_ids), try(each.value.managementGroup, ""))
    ? var.management_group_ids[each.value.managementGroup]
    : "/providers/Microsoft.Management/managementGroups/${var.root_management_group_id}"
  )

  depends_on = [azurerm_subscription.new]
}
