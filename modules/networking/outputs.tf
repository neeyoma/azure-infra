output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "web_subnet_id" {
  description = "The ID of the web subnet"
  value       = azurerm_subnet.web.id
}

output "app_subnet_id" {
  description = "The ID of the app subnet"
  value       = azurerm_subnet.app.id
}

output "db_subnet_id" {
  description = "The ID of the database subnet"
  value       = azurerm_subnet.db.id
}

output "load_balancer_id" {
  description = "The ID of the load balancer"
  value       = azurerm_lb.web_lb.id
}

output "load_balancer_backend_pool_id" {
  description = "The ID of the load balancer backend pool"
  value       = azurerm_lb_backend_address_pool.web_lb_backend.id
}

output "public_ip_address" {
  description = "The Public IP address of the load balancer"
  value       = azurerm_public_ip.lb_public_ip.ip_address
}
