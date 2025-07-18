output "vmss_id" {
  description = "ID of the Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.web_vmss.id
}

output "vmss_public_ip" {
  description = "Public IP address of the load balancer"
  value       = "Use networking module output"
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_linux_web_app.app_service.name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = "https://${azurerm_linux_web_app.app_service.default_hostname}"
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.sql_server.name
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.sql_database.name
}

output "sql_private_endpoint_fqdn" {
  description = "Private endpoint FQDN for SQL Database"
  value       = azurerm_private_endpoint.sql_private_endpoint.private_dns_zone_configs[0].record_sets[0].fqdn
}
