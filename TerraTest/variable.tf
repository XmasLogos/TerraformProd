variable "name_object"{
    type = object({
        location = string
        location_short = string
        usage = string
        env = string
        tag = string
        data_rg = string
    })
    default = {
        location = "southeastasia"
        location_short = "sea"
        usage = "tftest"
        env = "dev"
        tag = "terraform test"
        data_rg = "Xmas-Own"
    }
}

variable "subnet_address_prefixes" {
    type = list(list(string))
    default = [["172.16.1.0/26"], ["172.16.1.64/26"]]
    sensitive = true
}

variable "ip_object" {
    type = object({
      ip_sku = string
      sku_tier = string
      zones = list(string)
      private_ip_address = string
    })
    default = {
        ip_sku = "Standard"
        sku_tier = "Regional"
        zones = ["1","2","3"]
        private_ip_address = "172.16.1.4"
    }
}

variable "vm_object" {
  type = object({
        zones = list(string)
        vm_size = string
        username = string
        vm_image = object({
        publisher = string
        offer     = string
        sku       = string
        version   = string
        })
    })
    default = {
      zones = ["1","2","3"]
      vm_size = "Standard_D4as_v5"
      username = "linuxvm"
      vm_image = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }
    }
}

variable "subscription_id"{
  type = string
}
