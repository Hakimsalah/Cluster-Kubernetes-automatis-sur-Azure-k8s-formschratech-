# =====================
# PROVIDER
# =====================
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# =====================
# RESOURCE GROUP
# =====================
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# =====================
# NETWORK
# =====================
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# =====================
# SECURITY GROUP
# =====================
resource "azurerm_network_security_group" "nsg" {
  name                = "k8s-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "K8S_API"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# =====================
# VMS LOCAL VARIABLES
# =====================
locals {
  vms = {
    master = { size = var.vm_sizem }
    worker = { size = var.vm_sizew }
  }
}

# =====================
# PUBLIC IP
# =====================
resource "azurerm_public_ip" "pip" {
  for_each            = local.vms
  name                = "${each.key}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# =====================
# NETWORK INTERFACE
# =====================
resource "azurerm_network_interface" "nic" {
  for_each            = local.vms
  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  for_each                  = azurerm_network_interface.nic
  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# =====================
# LINUX VMS
# =====================
resource "azurerm_linux_virtual_machine" "vm" {
  for_each             = local.vms
  name                 = "${each.key}-vm"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  size                 = each.value.size
  admin_username       = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    role = each.key
  }
}

# =====================
# GENERATE ANSIBLE INVENTORY
# =====================
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    master_public_ip = azurerm_public_ip.pip["master"].ip_address
    worker_public_ip = azurerm_public_ip.pip["worker"].ip_address
  })
}
