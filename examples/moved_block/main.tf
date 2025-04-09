# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

module "avm-res-resources-resourcegroup" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"
  # insert the 2 required variables here

  enable_telemetry = var.enable_telemetry

  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique

  tags = {
    environment = "aztfexport-demo"
    createdBy   = "Donovan"
  }
}

resource "azurerm_virtual_network" "production" {
  address_space       = ["10.0.0.0/24"]
  location            = module.avm-res-resources-resourcegroup.resource.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = module.avm-res-resources-resourcegroup.name
}

moved {
  from = azurerm_virtual_network.example
  to   = azurerm_virtual_network.production
}

resource "azurerm_subnet" "rdp" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = module.avm-res-resources-resourcegroup.name
  virtual_network_name = azurerm_virtual_network.production.name
}

moved {
  from = azurerm_subnet.example
  to   = azurerm_subnet.rdp
}

# Resource to Module Call (iffy scenario)

/*
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "West Europe"
  tags    = {
    environment = "aztfexport-demo"
    createdBy   = "Donovan"
  }
}
*/

# /*
module "rg_moved" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"
  # insert the 2 required variables here

  enable_telemetry = var.enable_telemetry

  location = "West Europe"
  name     = "example"

  /*
  lock = {
    kind = "CanNotDelete"
    name = "example-lock"
  }
  */

  tags = {
    environment = "aztfexport-demo"
    createdBy   = "Donovan"
  }
}

moved {
  from = azurerm_resource_group.example
  to   = module.rg_moved.azurerm_resource_group.this
}
# */
