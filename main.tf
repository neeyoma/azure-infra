# Configuring the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

# Configuring the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# To get current client configuration
data "azurerm_client_config" "current" {}

# Existing Key Vault and secret
data "azurerm_key_vault" "existing" {
  name                = var.existing_key_vault_name
  resource_group_name = var.existing_key_vault_rg
}

data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = var.secret_name
  key_vault_id = data.azurerm_key_vault.existing.id
}

# Creating Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Deploying the networking module
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  web_subnet_prefix  = var.web_subnet_prefix
  app_subnet_prefix  = var.app_subnet_prefix
  db_subnet_prefix   = var.db_subnet_prefix
  tags               = var.tags
}

# Deploying the compute module
module "compute" {
  source = "./modules/compute"

  resource_group_name               = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  web_subnet_id                    = module.networking.web_subnet_id
  app_subnet_id                    = module.networking.app_subnet_id
  db_subnet_id                     = module.networking.db_subnet_id
  vnet_id                          = module.networking.vnet_id
  load_balancer_backend_pool_id    = module.networking.load_balancer_backend_pool_id
  admin_username                   = var.admin_username
  sql_admin_password               = data.azurerm_key_vault_secret.sql_admin_password.value
  key_vault_id                     = module.key_vault.key_vault_id
  tags                             = var.tags
}

# Deploying the security module
module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  web_subnet_id      = module.networking.web_subnet_id
  app_subnet_id      = module.networking.app_subnet_id
  db_subnet_id       = module.networking.db_subnet_id
  tags               = var.tags
}
