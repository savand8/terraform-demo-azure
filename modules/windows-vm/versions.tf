# -----------------------------------------------------------------------------
# versions.tf
# A module declares which providers it needs, but it doesn't configure them.
# The provider "azurerm" block lives in the root module and is passed down.
# -----------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
