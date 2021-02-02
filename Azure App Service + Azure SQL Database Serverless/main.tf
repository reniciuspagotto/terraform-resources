terraform {
  required_providers {
    azurerm = "2.41.0"
  }
  backend "azurerm" {
    storage_account_name = "pagottoterraform"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    access_key = "set here the blob key"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
    name     = var.resource_group_name
    location = var.resource_group_location
}

resource "azurerm_sql_server" "main" {
    name                         = var.sql_server_instance_name
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

resource "azurerm_mssql_database" "main" {
  name                        = var.sql_server_database_name
  server_id                   = azurerm_sql_server.main.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"

  auto_pause_delay_in_minutes = 60
  max_size_gb                 = 32
  min_capacity                = 0.5
  read_replica_count          = 0
  read_scale                  = false
  sku_name                    = "GP_S_Gen5_2"
  zone_redundant              = false

  threat_detection_policy {
    disabled_alerts      = []
    email_account_admins = "Disabled"
    email_addresses      = []
    retention_days       = 0
    state                = "Disabled"
    use_server_default   = "Disabled"
  }
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

    connection_string {
      name  = "PagottoApplication"
      type  = "SQLServer"
      value = "Server=tcp:${azurerm_sql_server.main.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${azurerm_sql_server.main.administrator_login};Password=${azurerm_sql_server.main.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    }
}