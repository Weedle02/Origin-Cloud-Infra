locals {
  rg_name      = "rg-platform-diagnostics"
  law_name     = "law-platform${var.name_suffix != "" ? "-${var.name_suffix}" : ""}"
  # Storage account names: 3-24 chars, lowercase alphanumeric only, globally unique.
  storage_name = substr("stplatformdiag${replace(var.name_suffix, "-", "")}", 0, 24)
}

resource "azurerm_resource_group" "diagnostics" {
  count    = var.enabled ? 1 : 0
  name     = local.rg_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "platform" {
  count               = var.enabled ? 1 : 0
  name                = local.law_name
  location            = azurerm_resource_group.diagnostics[0].location
  resource_group_name = azurerm_resource_group.diagnostics[0].name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
}

resource "azurerm_storage_account" "diagnostics" {
  count                    = var.enabled ? 1 : 0
  name                     = local.storage_name
  resource_group_name      = azurerm_resource_group.diagnostics[0].name
  location                 = azurerm_resource_group.diagnostics[0].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

# Onboard Sentinel only when explicitly enabled. Requires the Log Analytics workspace
# to exist first; Sentinel can be enabled at any time after initial deployment.
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "platform" {
  count        = var.enabled && var.enable_sentinel ? 1 : 0
  workspace_id = azurerm_log_analytics_workspace.platform[0].id
}
