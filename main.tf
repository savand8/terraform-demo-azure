# -----------------------------------------------------------------------------
# main.tf
# The shared pieces (resource group and network) live here. Everything a
# single VM needs is packaged up in the ./modules/windows-vm module.
# -----------------------------------------------------------------------------

# Locals are named values computed inside the config - handy to avoid repetition
locals {
  name = "${var.prefix}-${var.location}"

  common_tags = merge(var.tags, {
    managed_by = "terraform"
  })
}

# 1. Resource group - a container for everything else
resource "azurerm_resource_group" "demo" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = local.common_tags
}

# 2. Networking: virtual network + subnet, shared by every VM
resource "azurerm_virtual_network" "demo" {
  name                = "vnet-${local.name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "demo" {
  name                 = "snet-default"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 3. The VM, created by our module. Inputs go in as arguments;
#    results come back out as module.vm.<output>.
module "vm" {
  source = "./modules/windows-vm"

  name                = local.name
  computer_name       = "${var.prefix}-vm"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  subnet_id           = azurerm_subnet.demo.id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  allowed_rdp_cidr    = var.allowed_rdp_cidr
  tags                = local.common_tags
}
