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
    createdBy = "Donovan"
  }
}

resource "azurerm_virtual_network" "example" {
  address_space       = ["192.168.0.0/24"]
  location            = module.avm-res-resources-resourcegroup.resource.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = module.avm-res-resources-resourcegroup.name
}

resource "azurerm_subnet" "example" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = module.avm-res-resources-resourcegroup.name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_network_security_group" "example" {
  location            = module.avm-res-resources-resourcegroup.resource.location
  name                = module.naming.network_security_group.name_unique
  resource_group_name = module.avm-res-resources-resourcegroup.name
}

resource "azurerm_network_security_rule" "example" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "AllowAllRDPInbound"
  network_security_group_name = azurerm_network_security_group.example.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = module.avm-res-resources-resourcegroup.name
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

module "avm-res-compute-virtualmachine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.18.1"
  # insert the 5 required variables here

  enable_telemetry = var.enable_telemetry

  location            = module.avm-res-resources-resourcegroup.resource.location
  name                = module.naming.windows_virtual_machine.name_unique
  resource_group_name = module.avm-res-resources-resourcegroup.name
  zone                = null

  # Admin User
  admin_username = "azureuser"
  admin_password = var.admin_password

  encryption_at_host_enabled = false

  # Simple NIC with private and public IP address
  network_interfaces = {
    network_interface_1 = {
      name = "testnic1"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "testnic1-ipconfig1"
          private_ip_subnet_resource_id = azurerm_subnet.example.id
          create_public_ip_address      = true
          public_ip_address_name        = "vm1-testnic1-publicip1"
        }
      }
    }
  }

  tags = {
    environment = "aztfexport-demo"
  } 

}