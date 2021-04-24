terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
    name     = var.resource_group_name
    location = var.resource_group_location
}

resource "azurerm_app_service_plan" "main" {
    name                = var.app_service_plan_name
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    sku {
        tier = "Basic"
        size = "F1"
    }
}

resource "azurerm_app_service" "main" {
    name                = var.app_service_name
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    app_service_plan_id = azurerm_app_service_plan.main.id
}