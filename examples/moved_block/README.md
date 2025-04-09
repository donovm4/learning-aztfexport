# Renaming instances with the `moved` block

In this configuration, we are deploying a resource group and using the `moved` block to rename the instance within the state WITHOUT destroying the resource on a plan/apply.  

## Initial Infrastructure

```terraform
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
```

Apply this configuration so that the resources are among the following items tracked in the state:

- `azurerm_subnet.example`  
- `azurerm_virtual_network.example`  
- `module.avm-res-resources-resourcegroup.azurerm_resource_group.this`  

> run `terraform state list` to view the resources stored in the state

## Refactoring / Renaming a Resource

Let's say I wanted to rename the resource name/label for the virtual network or subnet. I can leverage a `moved` block.

The steps are simple for a basic scenario:

1. rename the resource block (or module call)
2. update references to the resource in the configuration
3. configure the `moved` block with the initial resource reference name and the target resource reference name

```terraform
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

resource "azurerm_virtual_network" "production" { # example --> production
  address_space       = ["10.0.0.0/24"]
  location            = module.avm-res-resources-resourcegroup.resource.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = module.avm-res-resources-resourcegroup.name
}

moved {
  from = azurerm_virtual_network.example
  to   = azurerm_virtual_network.production
}

resource "azurerm_subnet" "rdp" { # example --> rdp
  address_prefixes     = ["10.0.0.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = module.avm-res-resources-resourcegroup.name
  virtual_network_name = azurerm_virtual_network.production.name
}

moved {
  from = azurerm_subnet.example
  to   = azurerm_subnet.rdp
}
```

Result:

```terraform
Terraform will perform the following actions:

  # azurerm_subnet.example has moved to azurerm_subnet.rdp
    resource "azurerm_subnet" "rdp" {
        id                                            = "/subscriptions/.../resourceGroups/rg-lnjp/providers/Microsoft.Network/virtualNetworks/vnet-lnjp/subnets/snet-lnjp"
        name                                          = "snet-lnjp"
        # (8 unchanged attributes hidden)
    }

  # azurerm_virtual_network.example has moved to azurerm_virtual_network.production
    resource "azurerm_virtual_network" "production" {
        id                             = "/subscriptions/.../resourceGroups/rg-lnjp/providers/Microsoft.Network/virtualNetworks/vnet-lnjp"
        name                           = "vnet-lnjp"
        tags                           = {}
        # (10 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 0 to destroy.
```

This would work in a similar if I wanted to remane a module call.

## Refactoring a `resource` to `AVM` potentially

Let's start with another resource group instance:

```terraform
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "West Europe"
}
```

I want to migrate this resource instance to an AVM module for resource groups, so that I can leverage a Microsoft-supported module with backed best practices. Let's see if this is possible for my resource group.

This is what the new configuration code will be:

```terraform
module "rg_moved" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"
  # insert the 2 required variables here

  enable_telemetry = var.enable_telemetry

  location = "West Europe"
  name     = "example"

  tags = {
    environment = "aztfexport-demo"
  }
}

moved {
  from = azurerm_resource_group.example
  to   = module.rg_moved.azurerm_resource_group.this
}
```

I will need to run `terraform init` to import the module, and then I can run my plan or apply and test this out.

```terraform
Terraform will perform the following actions:

  # azurerm_resource_group.example has moved to module.rg_moved.azurerm_resource_group.this
    resource "azurerm_resource_group" "this" {
        id         = "/subscriptions/.../resourceGroups/example"
        name       = "example"
        tags       = {
            "createdBy"   = "Donovan"
            "environment" = "aztfexport-demo"
        }
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 0 to destroy.
```


Resource(s):

- [Refactoring Modules | HashiCorp](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring#refactoring)