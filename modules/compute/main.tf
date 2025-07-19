data "azurerm_key_vault" "existing" {
  name                = var.existing_key_vault_name
  resource_group_name = var.existing_key_vault_rg
}

data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = var.ssh_public_key_secret_name
  key_vault_id = data.azurerm_key_vault.existing.id
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = var.secret_name
  key_vault_id = data.azurerm_key_vault.existing.id
}

# The Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "vmss-web"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard_B2s"
  instances           = 2
  upgrade_mode        = "Automatic"

  # Disable password authentication
  disable_password_authentication = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss-web-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.web_subnet_id
      load_balancer_backend_address_pool_ids = [var.load_balancer_backend_pool_id]
    }
  }

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = data.azurerm_key_vault_secret.ssh_public_key.value
  }

  tags = var.tags
}

# The Autoscaling settings for VMSS
resource "azurerm_monitor_autoscale_setting" "web_vmss_autoscale" {
  name                = "vmss-web-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web_vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 5
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }

  tags = var.tags
}

# The App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "asp-backend"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"

  tags = var.tags
}

# The App Service
resource "azurerm_linux_web_app" "app_service" {
  name                = "app-backend-${random_string.app_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {}
    
   
  }

# The VNet Integration for App Service
resource "azurerm_app_service_virtual_network_swift_connection" "app_service_vnet_integration" {
  app_service_id = azurerm_linux_web_app.app_service.id
  subnet_id      = var.app_subnet_id
}

# The Random suffix for unique naming
resource "random_string" "app_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "sql_suffix" {
  length  = 8
  special = false
  upper   = false
}

# The SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-server-${random_string.sql_suffix.result}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = data.azurerm_key_vault_secret.sql_admin_password.value
  
  # Disabling public network access
  public_network_access_enabled = false

  tags = var.tags
}

# The SQL Database
resource "azurerm_mssql_database" "sql_database" {
  name           = "webapp-db"
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 20
  sku_name       = "S1"
  zone_redundant = false

  tags = var.tags
}

# The Private DNS Zone for SQL Server
resource "azurerm_private_dns_zone" "sql_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# The Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "pe-sql-server"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.db_subnet_id

  private_service_connection {
    name                           = "psc-sql-server"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_dns_zone.id]
  }

  tags = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_vnet_link" {
  name                  = "sql-dns-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
  virtual_network_id    = var.vnet_id

  tags = var.tags
}
