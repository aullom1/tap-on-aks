resource "azurerm_kubernetes_cluster" "default" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = 30
  }

  # service_principal {
  #   client_id     = var.azure_sp_client_id
  #   client_secret = var.azure_sp_client_secret
  # }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    profile = var.cluster_profile
  }
}
