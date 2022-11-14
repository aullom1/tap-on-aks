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
  default     = 1
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
