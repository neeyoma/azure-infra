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
