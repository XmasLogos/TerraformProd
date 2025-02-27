terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.20.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "Xmas-Own"
    storage_account_name = "xstoragesea001"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
    lock {
      enabled = true
    }
  }
}

provider "azurerm" {
  features{}
}
