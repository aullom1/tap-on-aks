terraform {
  azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.23.0"
  }
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

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

resource "azurerm_kubernetes_cluster" "default" {
  depends_on          = [azurerm_resource_group.default]
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${var.cluster_name}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.azure_sp_client_id
    client_secret = var.azure_sp_client_secret
  }

  tags = {
    profile = var.cluster_profile
  }
}
