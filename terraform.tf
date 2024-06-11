terraform {
  required_version = "~> 1.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  // TODO: Use remote state!
  features {
    # resource_group {
    #   prevent_deletion_if_contains_resources = false
    # }
  }
}

data "azurerm_client_config" "this" {}
