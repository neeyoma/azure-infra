variable "resource_group_name" {
  description = "The Name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the resources"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "web_subnet_prefix" {
  description = "The address prefix for the web subnet"
  type        = string
}

variable "app_subnet_prefix" {
  description = "The address prefix for the app subnet"
  type        = string
}

variable "db_subnet_prefix" {
  description = "Address prefix for the database subnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
}
