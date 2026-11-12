# -----------------------------------------------------------------------------
# variables.tf
# The module's inputs. A module can only see what the caller passes in here.
# -----------------------------------------------------------------------------

variable "name" {
  description = "Base name used for every resource in this module."
  type        = string
}

variable "computer_name" {
  description = "Windows hostname for the VM."
  type        = string

  validation {
    condition     = length(var.computer_name) <= 15
    error_message = "Windows hostnames can be at most 15 characters."
  }
}

variable "location" {
  description = "Azure region to deploy into."
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group to deploy into."
  type        = string
}

variable "subnet_id" {
  description = "ID of the existing subnet the VM connects to."
  type        = string
}

variable "vm_size" {
  description = "Size (SKU) of the virtual machine."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureuser"
}

variable "allowed_rdp_cidr" {
  description = "CIDR range allowed to RDP to the VM."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
