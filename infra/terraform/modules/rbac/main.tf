locals {
  platform         = yamldecode(file(var.platform_config_path))
  role_assignments = try(local.platform.roleAssignments, [])
}

# Role assignments are keyed by principalId__roleDefinitionName__scope to ensure
# uniqueness. Each entry in platform.yaml roleAssignments requires:
#   principalId, roleDefinitionName, scope
# Optional: principalType, skipServicePrincipalAadCheck
resource "azurerm_role_assignment" "platform" {
  for_each = {
    for ra in local.role_assignments :
    "${ra.principalId}__${ra.roleDefinitionName}__${ra.scope}" => ra
  }

  principal_id                     = each.value.principalId
  role_definition_name             = each.value.roleDefinitionName
  scope                            = each.value.scope
  principal_type                   = try(each.value.principalType, null)
  skip_service_principal_aad_check = try(each.value.skipServicePrincipalAadCheck, false)
}
