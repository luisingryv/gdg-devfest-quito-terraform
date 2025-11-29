output "dns_record_id" {
  description = "ID del registro DNS en Cloudflare"
  value       = cloudflare_record.dns_a.id
}

output "dns_record_name" {
  description = "Nombre del registro DNS"
  value       = cloudflare_record.dns_a.name
}

output "dns_record_value" {
  description = "Valor del registro DNS (IP del LB)"
  value       = cloudflare_record.dns_a.content # 'value' está deprecado, usar 'content'
}

output "full_domain" {
  description = "Dominio completo"
  value       = var.subdomain
}

output "www_domain" {
  description = "Dominio www (si se creó)"
  value       = var.create_www_record ? "www.${var.subdomain}" : null
}

