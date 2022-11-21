terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.23.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-vms"
    storage_account_name = "sauaaron"
    container_name       = "tap-tfstate"
    key                  = "terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_sp_client_id
  client_secret   = var.azure_sp_client_secret
  tenant_id       = var.azure_tenant_id
}

# Create a resource group
resource "azurerm_resource_group" "default" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    purpose = "TAP multi-cluster"
  }
}

resource "azurerm_container_registry" "acr" {
  depends_on             = [azurerm_resource_group.default]
  resource_group_name    = azurerm_resource_group.default.name
  location               = azurerm_resource_group.default.location
  name                   = "acrtapdemo"
}

# module "view_cluster" {
#   depends_on = [azurerm_resource_group.default]
#   source = "./aks"

#   resource_group_name    = azurerm_resource_group.default.name
#   location               = azurerm_resource_group.default.location
#   cluster_name           = "view"
#   node_count             = 2
#   # vm_size                = var.vm_size
#   cluster_profile        = "view"
# }

# module "build_cluster" {
#   depends_on = [azurerm_resource_group.default]
#   source = "./aks"

#   resource_group_name    = azurerm_resource_group.default.name
#   location               = azurerm_resource_group.default.location
#   cluster_name           = "build"
#   node_count             = 2
#   # vm_size                = var.vm_size
#   cluster_profile        = "build"
# }

# module "run_cluster" {
#   depends_on = [azurerm_resource_group.default]
#   source = "./aks"

#   resource_group_name    = azurerm_resource_group.default.name
#   location               = azurerm_resource_group.default.location
#   cluster_name           = "run"
#   node_count             = 1
#   # vm_size                = var.vm_size
#   cluster_profile        = "run"
# }

# module "iterate_cluster" {
#   depends_on = [azurerm_resource_group.default]
#   source = "./aks"

#   resource_group_name    = azurerm_resource_group.default.name
#   location               = azurerm_resource_group.default.location
#   cluster_name           = "iterate"
#   node_count             = 1
#   # vm_size                = var.vm_size
#   cluster_profile        = "iterate"
# }

output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "container_registry_name" {
  value = azurerm_container_registry.acr.name
}

output "container_registry_hostname" {
  value = azurerm_container_registry.acr.login_server
}

# output "view_cluster_name" {
#   value = module.view_cluster.cluster_name
# }

# output "build_cluster_name" {
#   value = module.build_cluster.cluster_name
# }

# output "run_cluster_name" {
#   value = module.run_cluster.cluster_name
# }

# output "iterate_cluster_name" {
#   value = module.iterate_cluster.cluster_name
# }
