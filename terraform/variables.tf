variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "azure_sp_client_id" {
  type        = string
  description = "Azure service principal client ID"
}

variable "azure_sp_client_secret" {
  type        = string
  description = "Azure service principal client secret"
  sensitive   = true
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for all resources"
}

variable "location" {
  type        = string
  description = "Location of all resources"
  default     = "East US 2"
}
