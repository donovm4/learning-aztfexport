resource "azurerm_resource_group" "res-0" {
  location = "canadacentral"
  name     = "rg-u92f"
  tags = {
    createdBy   = "Donovan"
    environment = "aztfexport-demo"
  }
}
