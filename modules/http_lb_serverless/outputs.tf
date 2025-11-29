output "lb_ip_address" {
  description = "IP pública del Load Balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "lb_ip_name" {
  description = "Nombre del recurso de IP"
  value       = google_compute_global_address.lb_ip.name
}

output "url_map_name" {
  description = "Nombre del URL Map"
  value       = google_compute_url_map.url_map.name
}

output "https_proxy_name" {
  description = "Nombre del HTTPS Proxy"
  value       = google_compute_target_https_proxy.https_proxy.name
}

output "ssl_certificate_name" {
  description = "Nombre del certificado SSL"
  value       = google_compute_managed_ssl_certificate.ssl_cert.name
}

# Nota: El estado del certificado SSL no está disponible directamente en el recurso
# Puedes verificar el estado usando: gcloud compute ssl-certificates describe <name>

output "frontend_url" {
  description = "URL del frontend (HTTP)"
  value       = "http://${google_compute_global_address.lb_ip.address}"
}

output "frontend_https_url" {
  description = "URL del frontend (HTTPS) - solo si hay dominio configurado"
  value       = length(var.ssl_domains) > 0 ? "https://${var.ssl_domains[0]}" : null
}

