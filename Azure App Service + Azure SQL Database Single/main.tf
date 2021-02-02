provider "azurerm" {
    version = "~>2.14.0"
    features {}
}

terraform {
  backend "azurerm" {
    storage_account_name = "pagotto"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    access_key = "set here the blob key"
  }
}

resource "azurerm_resource_group" "main" {
    name     = var.resource_group_name
    location = var.resource_group_location
}

resource "azurerm_sql_server" "main" {
    name                         = "online-consulting-pagotto-sqlserver"
    resource_group_name          = azurerm_resource_group.main.name
    location                     = azurerm_resource_group.main.location
    version                      = "12.0"
    administrator_login          = "youruser"
    administrator_login_password = "youruserpassword"
}

resource "azurerm_sql_firewall_rule" "main" {
  name                = "AlllowAzureServices"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_sql_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_database" "main" {
  name                             = "pagotto-application-database"
  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  server_name                      = azurerm_sql_server.main.name
  edition                          = "Basic"
#   requested_service_objective_name = "S0"
}

resource "azurerm_app_service_plan" "main" {
    name                = "pagotto-application-plan"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    sku {
        tier = "Basic"
        size = "F1"
    }
}

resource "azurerm_app_service" "main" {
    name                = "pagotto-application-appservice"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    app_service_plan_id = azurerm_app_service_plan.main.id

    connection_string {
      name  = "PagottoApplicationDatabase"
      type  = "SQLServer"
      value = "Server=tcp:${azurerm_sql_server.main.name}.database.windows.net,1433;Initial Catalog=${azurerm_sql_database.main.name};Persist Security Info=False;User ID=${azurerm_sql_server.main.administrator_login};Password=${azurerm_sql_server.main.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    }
}