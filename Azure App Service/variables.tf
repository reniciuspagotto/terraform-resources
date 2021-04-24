variable "resource_group_name" {
  type        = string
  default     = "PagottoTerraformMedium"
}

variable "resource_group_location" {
  type        = string
  default     = "Brazil South"
}

variable "app_service_plan_name" {
  type = string
  default = "pagotto-terraform-plan"
}

variable "app_service_name" {
  type = string
  default = "pagotto-terraform-appservice"
}