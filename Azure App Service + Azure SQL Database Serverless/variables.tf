variable "resource_group_name" {
  type        = string
  default     = "PagottoPlataform"
}

variable "resource_group_location" {
  type        = string
  default     = "Brazil South"
}

variable "sql_server_instance_name" {
  type = string
  default = "pagotto-sqlserver"
}

variable "sql_server_database_name" {
  type = string
  default = "pagotto-serverless-database"
}

variable "app_service_plan_name" {
  type = string
  default = "pagotto-application-plan"
}

variable "app_service_name" {
  type = string
  default = "pagotto-appservice"
}