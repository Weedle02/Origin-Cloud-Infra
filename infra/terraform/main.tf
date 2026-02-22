module "management_groups" {
  source               = "./modules/management_groups"
  platform_config_path = var.platform_config_path
}

module "subscription_factory" {
  source                   = "./modules/subscription_factory"
  platform_config_path     = var.platform_config_path
  root_management_group_id = module.management_groups.root_management_group_id
  management_group_ids     = module.management_groups.management_group_ids
  billing_scope_id         = var.billing_scope_id
  depends_on               = [module.management_groups]
}

module "policies" {
  source                   = "./modules/policies"
  platform_config_path     = var.platform_config_path
  policy_assignments_path  = var.policy_assignments_path
  root_management_group_id = module.management_groups.root_management_group_id
  depends_on               = [module.management_groups, module.subscription_factory]
}

module "diagnostics" {
  source          = "./modules/diagnostics"
  location        = var.location
  enabled         = var.enable_diagnostics
  enable_sentinel = var.enable_sentinel
  name_suffix     = var.diagnostics_name_suffix
  depends_on      = [module.management_groups, module.subscription_factory]
}

module "rbac" {
  source               = "./modules/rbac"
  platform_config_path = var.platform_config_path
  management_group_ids = module.management_groups.management_group_ids
  depends_on           = [module.management_groups, module.subscription_factory]
}
