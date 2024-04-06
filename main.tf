terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  #skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}


# Create a resource group
resource "azurerm_resource_group" "nvs-rg" {
  name     = "nvs-rg"
  location = "West Us"
  tags = {
    environment = "dev"
  }
}

# Create a virtual network within the resource group

resource "azurerm_virtual_network" "nvs-net" {
  name                = "nvs-network"
  resource_group_name = azurerm_resource_group.nvs-rg.name
  location            = azurerm_resource_group.nvs-rg.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "dev"
  }
}


resource "azurerm_subnet" "nvs-subnet" {
  name                 = "nvs-subnet"
  resource_group_name  = azurerm_resource_group.nvs-rg.name
  virtual_network_name = azurerm_virtual_network.nvs-net.name
  address_prefixes     = ["10.0.1.0/24"]


}

resource "azurerm_network_security_group" "nvs-sg" {
  name                = "nvs-security-group"
  location            = azurerm_resource_group.nvs-rg.location
  resource_group_name = azurerm_resource_group.nvs-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "nvs-kafka-sr" {
  name                        = "nvs-kafka-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.nvs-rg.name
  network_security_group_name = azurerm_network_security_group.nvs-sg.name


}


resource "azurerm_subnet_network_security_group_association" "nvs-subnet-sg-ass" {
  subnet_id                 = azurerm_subnet.nvs-subnet.id
  network_security_group_id = azurerm_network_security_group.nvs-sg.id
}


resource "azurerm_public_ip" "nvsp-ip" {
  name                = "dev-machine-p-ip"
  resource_group_name = azurerm_resource_group.nvs-rg.name
  location            = azurerm_resource_group.nvs-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}



resource "azurerm_network_interface" "nvs-nic" {
  name                = "nvs-nic"
  location            = azurerm_resource_group.nvs-rg.location
  resource_group_name = azurerm_resource_group.nvs-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nvs-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nvsp-ip.id
  }

  tags = {
    environment = "dev"
  }
}


resource "azurerm_linux_virtual_machine" "dev-vm-001" {
  name                = "dev-vm-001"
  resource_group_name = azurerm_resource_group.nvs-rg.name
  location            = azurerm_resource_group.nvs-rg.location
  size                = "Standard_B1s"
  admin_username      = "rootUser"
  network_interface_ids = [
    azurerm_network_interface.nvs-nic.id,
  ]

  custom_data = filebase64("customdata.tpl")


  admin_ssh_key {
    username   = "rootUser"
    public_key = file("C:\\Users\\Precision\\.ssh\\nvsdevmachinekey.pub")
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      user         = "rootUser",
      identityfile = "C:\\Users\\Precision\\.ssh\\nvsdevmachinekey"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]

  }

}

data "azurerm_public_ip" "nvs-ip-data" {
  name                = azurerm_public_ip.nvsp-ip.name
  resource_group_name = azurerm_resource_group.nvs-rg.name

}


output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.dev-vm-001.name}: ${data.azurerm_public_ip.nvs-ip-data.ip_address}"
}
