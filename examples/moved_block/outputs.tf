output "resource_group" {
  description = "Important information about the resource group."
  value = {
    name     = module.avm-res-resources-resourcegroup.name
    location = module.avm-res-resources-resourcegroup.resource.location
    tags     = module.avm-res-resources-resourcegroup.resource.tags
    id       = module.avm-res-resources-resourcegroup.resource_id
  }

}