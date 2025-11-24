terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "platform_config_path" {
  type        = string
  description = "Path to the platform configuration manifest"
  default     = "platform/config/platform.yaml"
}

variable "location" {
  type        = string
  description = "Primary location for shared resources"
  default     = "eastus"
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to deploy shared diagnostic resources"
  default     = true
}

module "management_groups" {
  source              = "./modules/management_groups"
  platform_config_path = var.platform_config_path
}

module "subscription_factory" {
  source              = "./modules/subscription_factory"
  platform_config_path = var.platform_config_path
  depends_on           = [module.management_groups]
}

module "policies" {
  source              = "./modules/policies"
  platform_config_path = var.platform_config_path
  depends_on           = [module.management_groups, module.subscription_factory]
}

module "diagnostics" {
  source    = "./modules/diagnostics"
  location  = var.location
  enabled   = var.enable_diagnostics
  depends_on = [module.management_groups, module.subscription_factory]
}
