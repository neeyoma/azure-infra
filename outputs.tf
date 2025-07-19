output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "web_subnet_id" {
  description = "The ID of the Web Subnet"
  value       = module.networking.web_subnet_id
}

output "app_subnet_id" {
  description = "The ID of the App Subnet"
  value       = module.networking.app_subnet_id
}

output "db_subnet_id" {
  description = "The ID of the Database Subnet"
  value       = module.networking.db_subnet_id
}

output "vmss_id" {
  description = "The ID of the Virtual Machine Scale Set"
  value       = module.compute.vmss_id
}

output "vmss_public_ip" {
  description = "The Public IP address of the Load Balancer"
  value       = module.networking.public_ip_address
}

output "app_service_name" {
  description = "The name of the App Service"
  value       = module.compute.app_service_name
}

output "app_service_url" {
  description = "Thw URL of the App Service"
  value       = module.compute.app_service_url
}

output "sql_server_name" {
  description = "The name of the SQL Server"
  value       = module.compute.sql_server_name
}

output "sql_database_name" {
  description = "The name of the SQL Database"
  value       = module.compute.sql_database_name
}

output "sql_private_endpoint_fqdn" {
  description = "The private endpoint FQDN for SQL Database"
  value       = module.compute.sql_private_endpoint_fqdn
}



