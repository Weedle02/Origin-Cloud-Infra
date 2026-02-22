locals {
  platform           = yamldecode(file(var.platform_config_path))
  policy_manifest    = jsondecode(file(var.policy_assignments_path))
  policy_assignments = try(local.policy_manifest.policyAssignments, [])
}

resource "azurerm_policy_assignment" "baseline" {
  for_each = {
    for assignment in local.policy_assignments : assignment.name => assignment
  }

  name                 = each.value.name
  display_name         = try(each.value.displayName, each.value.name)
  scope                = "/providers/Microsoft.Management/managementGroups/${var.root_management_group_id}"
  policy_definition_id = each.value.policyDefinitionId
  description          = try(each.value.description, null)
  metadata             = jsonencode(try(each.value.metadata, { assignedBy = "Terraform" }))
  parameters           = jsonencode(try(each.value.params, {}))
  enforcement_mode     = try(each.value.enforcementMode, "Default")
}
