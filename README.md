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

## Notes

- The generated admin password is stored in the Terraform state. That's fine for a demo, but use a secrets store like Azure Key Vault in production.
- `allowed_rdp_cidr` has no default and isn't set in `terraform.tfvars`, so Terraform prompts for it. You can also pass it with `-var="allowed_rdp_cidr=<your-ip>/32"` or the `TF_VAR_allowed_rdp_cidr` environment variable. Validation rejects `0.0.0.0/0` because open RDP ports get scanned quickly. Find your IP with `curl ifconfig.me`.
- Remember to run `terraform destroy` at the end.
