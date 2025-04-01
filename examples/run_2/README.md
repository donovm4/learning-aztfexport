# Importing resources

## Prerequisites

- install the `aztfexport` tooling
- ensure that target infrastructure exists in Azure

## Command Line

``` terraform
aztfexport resource-group <resource-group-name>
```

## Resulting configuration files

- resource mapping in json
- provider.tf
- terraform.tf
- terraform.tfstate
