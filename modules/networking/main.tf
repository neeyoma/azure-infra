# Creating the Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Creating the Web Subnet
resource "azurerm_subnet" "web" {
  name                 = "WebSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.web_subnet_prefix]
}

# Creating the App Subnet
resource "azurerm_subnet" "app" {
  name                 = "AppSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.app_subnet_prefix]

  delegation {
    name = "app_service_delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Creating the Database Subnet
resource "azurerm_subnet" "db" {
  name                 = "DBSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.db_subnet_prefix]

}

# The Public IP for the Load Balancer
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "pip-lb-web"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# The Load Balancer for the VMSS
resource "azurerm_lb" "web_lb" {
  name                = "lb-web"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }

  tags = var.tags
}

# The Load Balancer for the Backend Pool
resource "azurerm_lb_backend_address_pool" "web_lb_backend" {
  loadbalancer_id = azurerm_lb.web_lb.id
  name            = "BackEndAddressPool"
}

# The Load Balancer for the Health Probe
resource "azurerm_lb_probe" "web_lb_probe" {
  loadbalancer_id = azurerm_lb.web_lb.id
  name            = "http-probe"
  port            = 80
}

# The Load Balancer Rule for HTTP
resource "azurerm_lb_rule" "web_lb_rule_http" {
  loadbalancer_id                = azurerm_lb.web_lb.id
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web_lb_backend.id]
  probe_id                       = azurerm_lb_probe.web_lb_probe.id
}

# The Load Balancer Rule for HTTPS
resource "azurerm_lb_rule" "web_lb_rule_https" {
  loadbalancer_id                = azurerm_lb.web_lb.id
  name                           = "HTTPS"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web_lb_backend.id]
  probe_id                       = azurerm_lb_probe.web_lb_probe.id
}
