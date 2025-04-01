# Importing resources

## Prerequisites

- install the `aztfexport` tooling
- ensure that target infrastructure exists in Azure
- remove the terraform files if there are any pre-existing artifacts, such as:
  - provider.tf
  - terraform.tf
  - main.tf

## Command Line

``` terraform
aztfexport resource-group <resource-group-name>
```

## Resulting configuration files

- resource mapping in json
- provider.tf
- terraform.tf
- terraform.tfstate
