terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }

  # Remote state — run `terraform init -migrate-state` if upgrading from local state.
  # Override resource_group_name / storage_account_name with -backend-config flags or a
  # partial backend config file (e.g. backend.hcl) for environment-specific deployments.
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateorigin"
    container_name       = "tfstate"
    key                  = "platform.tfstate"
  }
}
