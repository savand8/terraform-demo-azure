# -----------------------------------------------------------------------------
# providers.tf
# Tells Terraform which version it needs and which providers (plugins) to
# download. `terraform init` reads this file.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # The Azure provider - talks to the Azure Resource Manager API
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    # Generates a strong admin password for us, so the demo has no prerequisites
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}

  # azurerm v4 requires a subscription ID. Set it in terraform.tfvars,
  # or leave the variable empty and export ARM_SUBSCRIPTION_ID instead.
  subscription_id = var.subscription_id != "" ? var.subscription_id : null
}
