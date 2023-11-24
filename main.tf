# Create a resource group
resource "azurerm_resource_group" "test-rg" {
  name     = "my-rg"
  location = "East US"

}
# create acr Container registery
resource "azurerm_container_registry" "acr" {
  name                = "premacontainerRegistry"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
  sku                 = "Standard"
  admin_enabled       = false
}
# create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "test-aks"
  location            = azurerm_resource_group.test-rg.location
  resource_group_name = azurerm_resource_group.test-rg.name
  dns_prefix          = "testaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_A2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}
# create role assignment for aks acr pull
resource "azurerm_role_assignment" "myrole" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}


