variable "resource_group_name" {
  description = "The Name of the resource group"
  type        = string
  default     = "rg-webapp-infrastructure"
}

variable "location" {
  description = "The Azure region for resources"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "The Name of the virtual network"
  type        = string
  default     = "vnet-webapp"
}

variable "vnet_address_space" {
  description = "The Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "web_subnet_prefix" {
  description = "The Address prefix for the web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_subnet_prefix" {
  description = "The Address prefix for the app subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_subnet_prefix" {
  description = "The Address prefix for the database subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "admin_username" {
  description = "The Admin username for the VMs"
  type        = string
  default     = "azureuser"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "WebApp-Infrastructure-Project"
    Owner       = "NetEng"
  }
}

variable "existing_key_vault_name" {
  type        = string
  description = "Name of the existing Azure Key Vault"
  default     = "kv-web-infra"
}

variable "existing_key_vault_rg" {
  type        = string
  description = "Resource Group of the existing Azure Key Vault"
  default     = "rg-web-infra-kv"
}

variable "secret_name" {
  type        = string
  description = "Name of the secret to fetch from the Key Vault"
  default     = sqladminpass
}

variable "ssh_public_key_secret_name" {
  type        = string
  description = "ssh key used to gain access to VMSS instances"
  default     = "infrawebadmin"
}
