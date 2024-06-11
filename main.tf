module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"
}

resource "azurerm_resource_group" "this" {
  location = module.regions.regions_by_name["eastus"].name
  name     = module.naming.resource_group.name_unique
}

module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.2"

  name                = module.naming.virtual_network.name
  enable_telemetry    = true
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  address_space = var.address_space

  subnets = {
    privateendpoints = {
      name = "PrivateEndpointSubnet"
      // TODO: Use cidr functions to calculate
      address_prefixes = ["10.0.0.0/24"]
    }
  }
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

module "keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.6"

  name                          = module.naming.key_vault.name_unique
  enable_telemetry              = true
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  tenant_id                     = data.azurerm_client_config.this.tenant_id
  public_network_access_enabled = false

  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
      subnet_resource_id            = module.vnet.subnets["privateendpoints"].resource_id
    }
  }
}
