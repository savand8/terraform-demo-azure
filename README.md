# Terraform on Azure: intro demo

A small Terraform configuration that deploys a Windows Server 2022 virtual machine to Azure, with just enough networking to connect to it over Remote Desktop.

## What gets created

| Resource | Purpose |
| --- | --- |
| Resource group | Container for everything below |
| Virtual network and subnet | Private network for the VM |
| Public IP | So we can reach the VM |
| Network security group | Firewall rule allowing RDP (port 3389) |
| Network interface | Connects the VM to the subnet and public IP |
| Admin password (`random` provider) | Generated so there are no prerequisites |
| Windows VM (`Standard_B2s`) | The star of the show |

## Files

| File | What it's for |
| --- | --- |
| `providers.tf` | Terraform version, required providers and provider config |
| `variables.tf` | Input variable declarations, with types, defaults and validation |
| `terraform.tfvars` | Values for those variables (loaded automatically) |
| `main.tf` | The resources, plus `locals` |
| `outputs.tf` | Values printed after apply, including a sensitive one |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.5 or later
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), logged in with `az login`
- Your subscription ID in `terraform.tfvars`, or exported as `ARM_SUBSCRIPTION_ID`

## Demo script

```powershell
# 1. Download the providers
terraform init

# 2. Tidy and check the code
terraform fmt
terraform validate

# 3. Preview the changes
terraform plan

# 4. Create the resources (type "yes" to confirm). The Windows VM takes a few minutes.
terraform apply

# 5. Look at the outputs
terraform output
terraform output public_ip_address
terraform output -raw admin_password    # sensitive output

# 6. Connect over Remote Desktop (log in as azureuser with the password above)
mstsc /v:$(terraform output -raw public_ip_address)

# 7. Inspect the state
terraform state list
terraform state show azurerm_windows_virtual_machine.demo

# 8. Try a change: edit a tag in terraform.tfvars, then plan again
terraform plan

# 9. Override a variable from the command line
terraform plan -var="vm_size=Standard_B2ms"

# 10. Clean up so you're not billed
terraform destroy
```

## Part 2: modules (this branch)

On this branch, everything a single VM needs is packaged as a reusable module in `modules/windows-vm`. The root config keeps the shared resource group and network, then calls the module.

```
modules/windows-vm/
├── versions.tf    # required providers (no provider block - that stays in the root)
├── variables.tf   # the module's inputs
├── main.tf        # public IP, NSG, NIC, password, VM
└── outputs.tf     # what the caller can see, as module.vm.<output>
```

```powershell
# 1. Switch branch and re-initialise (Terraform needs to install the module)
git checkout 02-modules
terraform init

# 2. Note the new resource addresses, e.g. module.vm.azurerm_windows_virtual_machine.this
terraform plan
```

### Showing reuse: two VMs from one module

Change the module block in `main.tf` to use `for_each`:

```hcl
module "vm" {
  source   = "./modules/windows-vm"
  for_each = toset(["web", "app"])

  name                = "${local.name}-${each.key}"
  computer_name       = "${var.prefix}-${each.key}"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  subnet_id           = azurerm_subnet.demo.id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  allowed_rdp_cidr    = var.allowed_rdp_cidr
  tags                = local.common_tags
}
```

The root outputs then need to loop over the instances too, for example:

```hcl
output "public_ip_address" {
  value = { for k, vm in module.vm : k => vm.public_ip_address }
}
```

Run `terraform plan` to see two complete VMs.

## Notes

- The generated admin password is stored in the Terraform state. That's fine for a demo, but use a secrets store like Azure Key Vault in production.
- `allowed_rdp_cidr` has no default and isn't set in `terraform.tfvars`, so Terraform prompts for it. You can also pass it with `-var="allowed_rdp_cidr=<your-ip>/32"` or the `TF_VAR_allowed_rdp_cidr` environment variable. Validation rejects `0.0.0.0/0` because open RDP ports get scanned quickly. Find your IP with `curl ifconfig.me`.
- Remember to run `terraform destroy` at the end.
