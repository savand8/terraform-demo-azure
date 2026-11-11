# -----------------------------------------------------------------------------
# variables.tf
# Input variables: the "parameters" of our configuration.
# Values come from terraform.tfvars, -var flags, or TF_VAR_* env variables.
# -----------------------------------------------------------------------------

variable "subscription_id" {
  description = "Azure subscription ID to deploy into (leave empty to use ARM_SUBSCRIPTION_ID)."
  type        = string
  default     = ""
}

variable "prefix" {
  description = "Short prefix used in the name of every resource."
  type        = string
  default     = "tfdemo"

  # Validation blocks catch bad input before anything is deployed
  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.prefix))
    error_message = "prefix must be 3-10 lowercase letters or numbers."
  }
}

variable "location" {
  description = "Azure region to deploy into."
  type        = string
  default     = "uksouth"
}

variable "vm_size" {
  description = "Size (SKU) of the virtual machine."
  type        = string
  default     = "Standard_B2s" # Windows needs more memory than the 1 GB B1s
}

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureuser"
}

variable "allowed_rdp_cidr" {
  description = "CIDR range allowed to RDP to the VM, e.g. \"<your-public-ip>/32\". No default - you must set this explicitly."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_rdp_cidr, 0)) && !contains(["0.0.0.0/0", "*", "Internet", "Any"], var.allowed_rdp_cidr)
    error_message = "allowed_rdp_cidr must be a valid CIDR (e.g. \"203.0.113.10/32\") and must not open RDP to the whole internet."
  }
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
