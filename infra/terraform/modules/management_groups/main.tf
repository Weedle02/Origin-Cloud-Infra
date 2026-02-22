locals {
  platform                 = yamldecode(file(var.platform_config_path))
  management_groups        = try(local.platform.managementGroups, [])
  root_management_group_id = try(local.platform.rootManagementGroupId, null)
  management_group_map = {
    for group in local.management_groups : group.name => group
  }
}

data "azurerm_management_group" "root" {
  name = local.root_management_group_id
}

resource "azurerm_management_group" "groups" {
  for_each     = local.management_group_map
  name         = each.value.name
  display_name = each.value.displayName
  parent_management_group_id = (
    contains(keys(local.management_group_map), try(each.value.parent, ""))
    ? azurerm_management_group.groups[each.value.parent].id
    : data.azurerm_management_group.root.id
  )
}
