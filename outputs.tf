# -----------------------------------------------------------------------------
# outputs.tf
# Values Terraform prints after `apply`. View them again any time with
# `terraform output` or `terraform output <name>`.
# -----------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the resource group that holds everything."
  value       = azurerm_resource_group.demo.name
}

output "vm_name" {
  description = "Name of the virtual machine."
  value       = azurerm_windows_virtual_machine.demo.name
}

output "public_ip_address" {
  description = "Public IP address of the VM."
  value       = azurerm_public_ip.demo.ip_address
}

output "private_ip_address" {
  description = "Private IP address of the VM inside the VNet."
  value       = azurerm_network_interface.demo.private_ip_address
}

output "admin_username" {
  description = "Username to log in to the VM with."
  value       = var.admin_username
}

# Outputs can be built from expressions, not just single attributes
output "rdp_command" {
  description = "Command to open Remote Desktop to the VM."
  value       = "mstsc /v:${azurerm_public_ip.demo.ip_address}"
}

# Sensitive outputs are hidden in the CLI output.
# Reveal with: terraform output -raw admin_password
output "admin_password" {
  description = "Generated admin password for the VM."
  value       = random_password.admin.result
  sensitive   = true
}
