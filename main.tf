data "azurerm_key_vault" "kv-tftest-dev-sea-001" {
  name                = "kv-own-prod-sea-001"
  resource_group_name = var.name_object.data_rg
}

data "azurerm_key_vault_secret" "vm-secret" {
  name      = "vm-secret"
  key_vault_id = data.azurerm_key_vault.kv-tftest-dev-sea-001.id
}

data "azurerm_storage_account" "sa-tftest-dev-sea-001" {
   name                = "xstoragesea"
   resource_group_name = var.name_object.data_rg
}

resource "azurerm_resource_group" "rg-tftest-dev-sea-001" {
  name     = "rg-${var.name_object.usage}-${var.name_object.env}-${var.name_object.location_short}-001"
  location = var.name_object.location
}

resource "azurerm_network_security_group" "nsg-tftest-dev-sea-001" {
  name                = "nsg-${var.name_object.usage}-${var.name_object.env}-${var.name_object.location_short}-001"
  location            = var.name_object.location
  resource_group_name = azurerm_resource_group.rg-tftest-dev-sea-001.name

  security_rule {
    name                       = "testrule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "172.16.0.0/24"
    destination_address_prefix = "172.16.1.4"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "vnet-tftest-dev-sea-001" {
  name                = "vnet-${var.name_object.usage}-${var.name_object.env}-${var.name_object.location_short}-001"
  location            = var.name_object.location
  resource_group_name = azurerm_resource_group.rg-tftest-dev-sea-001.name
  address_space       = ["172.16.1.0/24"]

  tags = {
    environment = "tftest"
  }
}

resource "azurerm_subnet" "subnet-tftest-dev-sea-001" {
  name                 = "subnet-${var.name_object.usage}-${var.name_object.env}-${var.name_object.location_short}-001"
  address_prefixes     = var.subnet_address_prefixes[0]
  resource_group_name  = azurerm_resource_group.rg-tftest-dev-sea-001.name
  virtual_network_name = azurerm_virtual_network.vnet-tftest-dev-sea-001.name
}

resource "azurerm_subnet" "subnet-tftest-dev-sea-002" {
  name                 = "subnet-${var.name_object.usage}-${var.name_object.env}-${var.name_object.location_short}-002"
  address_prefixes     = var.subnet_address_prefixes[1]
  resource_group_name  = azurerm_resource_group.rg-tftest-dev-sea-001.name
  virtual_network_name = azurerm_virtual_network.vnet-tftest-dev-sea-001.name
}

resource "azurerm_subnet_network_security_group_association" "subnet-nsg-association-001" {
  subnet_id                 = azurerm_subnet.subnet-tftest-dev-sea-001.id
  network_security_group_id = azurerm_network_security_group.nsg-tftest-dev-sea-001.id
}

resource "azurerm_public_ip" "ip-tftest-dev-sea-001" {
  name                    = "ip-${var.name_object.usage}-${var.name_object.env}-${var.name_object.location_short}-001"
  location                = var.name_object.location
  resource_group_name     = azurerm_resource_group.rg-tftest-dev-sea-001.name
  allocation_method       = "Static"
  sku                     = var.ip_object.ip_sku
  sku_tier                = var.ip_object.sku_tier
  zones                   = var.ip_object.zones
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "nic-tftest-dev-sea-001" {
  name                           = "nic-${var.name_object.usage}-${var.name_object.env}-${var.name_object.location_short}-001"
  location                       = var.name_object.location
  resource_group_name            = azurerm_resource_group.rg-tftest-dev-sea-001.name
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "ipconfiguration1"
    subnet_id                     = azurerm_subnet.subnet-tftest-dev-sea-001.id
    primary                       = true
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.16.1.4"
    public_ip_address_id          = azurerm_public_ip.ip-tftest-dev-sea-001.id
  }
}


resource "azurerm_linux_virtual_machine" "vm-tftest-dev-sea-001" {
  name                  = "linuxvm-${var.name_object.usage}-${var.name_object.env}-${var.name_object.location_short}-001"
  resource_group_name   = azurerm_resource_group.rg-tftest-dev-sea-001.name
  location              = var.name_object.location
  size                  = var.vm_object.vm_size
  network_interface_ids =  [azurerm_network_interface.nic-tftest-dev-sea-001.id]
  admin_username        = var.vm_object.username
  admin_password = data.azurerm_key_vault_secret.vm-secret.value
  priority              = "Spot"
  eviction_policy       = "Deallocate"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    name                 = "osdisk-linux001-${var.name_object.usage}-${var.name_object.env}-${var.name_object.location_short}-001"
    disk_size_gb         = "256"
  }
  
  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.sa-tftest-dev-sea-001.primary_blob_endpoint
  }

  source_image_reference {
    publisher = var.vm_object.vm_image.publisher
    offer     = var.vm_object.vm_image.offer
    sku       = var.vm_object.vm_image.sku
    version   = var.vm_object.vm_image.version
  }
}








# resource "azurerm_iothub" "iothub_own_prod_iotest_001" {
#     name                         = "iothub"
#     resource_group_name          = azurerm_resource_group.rg-own-prod-iotest-001.name
#     location                     = azurerm_resource_group.rg-own-prod-iotest-001.location
#     local_authentication_enabled = false

#   sku {
#     name     = "S1"
#     capacity = "1"
#   }
# }
