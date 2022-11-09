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

variable "cluster_name" {
  type        = string
  description = "Name of the cluster to create"
}

variable "node_count" {
  type        = number
  description = "The number of nodes"
  default     = 2
}

variable "vm_size" {
  type        = string
  description = "VM size"
  default     = "Standard_D2_v2"
}

variable "cluster_profile" {
  type        = string
  description = "The TAP profile to use: full, iterate, build, run, view"
}
