# learning-aztfexport

Microsoft Documentation: [Overview of Azure Export for Terraform](https://learn.microsoft.com/en-us/azure/developer/terraform/azure-export-for-terraform/export-terraform-overview)

YouTube resource: [Azure Export for Terraform](https://www.youtube.com/watch?v=LWk9SU7AmDA)

## Questions

- What (or who) brought about this desire to move to Terraform management?
- Is the goal to manage a full environment?
- Are you trying to build configuration templates?
- Any thoughts or awareness on IaC being used to group common lifecycle resources together? (sometimes even managed by the same team)

## Demos

### Refactoring with the `moved` block (potentially migrating to AVM as well)

- Follow steps in `examples`/`moved_block`/`README.md`

### Exporting using aztfexport tool

1. Execute terraform configuration for `examples`/`run_1`
2. Leverage `aztfexport` in `examples`/`run_2` to import resource(s)

## Feasibility Checks

- Limitations with AVM
  - potential is there

- Limitations outside of AVM

> In both scenarios, I believe there is no SLA associated with `aztfexport` picking up 100% of resources.
