output "project_id" {
  description = "ID del proyecto GCP"
  value       = module.project.project_id
}

output "region" {
  description = "Región de GCP"
  value       = var.region
}

# Cloud SQL
output "database_connection_name" {
  description = "Connection name de Cloud SQL"
  value       = module.cloud_sql.connection_name
}

output "database_name" {
  description = "Nombre de la base de datos"
  value       = module.cloud_sql.database_name
}

output "database_user" {
  description = "Usuario de la base de datos"
  value       = module.cloud_sql.database_user
}

# Cloud Run
output "backend_service_url" {
  description = "URL del servicio backend (Cloud Run)"
  value       = module.cloud_run_backend.service_url
}

output "frontend_service_url" {
  description = "URL del servicio frontend (Cloud Run)"
  value       = module.cloud_run_frontend.service_url
}

# Load Balancer
output "load_balancer_ip" {
  description = "IP pública del Load Balancer"
  value       = module.http_lb.lb_ip_address
}

output "load_balancer_http_url" {
  description = "URL HTTP del Load Balancer"
  value       = module.http_lb.frontend_url
}

output "load_balancer_https_url" {
  description = "URL HTTPS del Load Balancer (si hay dominio configurado)"
  value       = module.http_lb.frontend_https_url
}

# Cloudflare DNS
# Usamos solo zone_id y domain_name para evitar usar variable sensible en condición
output "dns_domain" {
  description = "Dominio DNS configurado en Cloudflare"
  value       = var.cloudflare_zone_id != "" && var.domain_name != "" ? "${var.environment_subdomain}.${var.domain_name}" : null
}

output "frontend_final_url" {
  description = "URL final del frontend (con dominio si está configurado)"
  value       = var.domain_name != "" && var.cloudflare_zone_id != "" ? "https://${var.environment_subdomain}.${var.domain_name}" : module.http_lb.frontend_url
}

output "backend_final_url" {
  description = "URL final del backend (con dominio si está configurado)"
  value       = var.domain_name != "" && var.cloudflare_zone_id != "" ? "https://${var.environment_subdomain}.${var.domain_name}/api" : "${module.http_lb.frontend_url}/api"
}

