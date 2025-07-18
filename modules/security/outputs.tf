output "web_nsg_id" {
  description = "ID of the web network security group"
  value       = azurerm_network_security_group.web_nsg.id
}

output "app_nsg_id" {
  description = "ID of the app network security group"
  value       = azurerm_network_security_group.app_nsg.id
}

output "db_nsg_id" {
  description = "ID of the database network security group"
  value       = azurerm_network_security_group.db_nsg.id
}
