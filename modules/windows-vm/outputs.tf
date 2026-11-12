# -----------------------------------------------------------------------------
# outputs.tf
# The module's outputs. The caller can only see what's exposed here,
# as module.<name>.<output>.
# -----------------------------------------------------------------------------

output "vm_name" {
  description = "Name of the virtual machine."
  value       = azurerm_windows_virtual_machine.this.name
}

output "public_ip_address" {
  description = "Public IP address of the VM."
  value       = azurerm_public_ip.this.ip_address
}

output "private_ip_address" {
  description = "Private IP address of the VM inside the VNet."
  value       = azurerm_network_interface.this.private_ip_address
}

output "admin_username" {
  description = "Username to log in to the VM with."
  value       = var.admin_username
}

output "admin_password" {
  description = "Generated admin password for the VM."
  value       = random_password.admin.result
  sensitive   = true
}
