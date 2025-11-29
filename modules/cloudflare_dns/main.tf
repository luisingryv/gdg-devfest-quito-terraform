# Módulo de Cloudflare DNS
# Crea registros DNS apuntando al Load Balancer de GCP

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Registro A apuntando a la IP del Load Balancer
resource "cloudflare_record" "dns_a" {
  zone_id = var.zone_id
  name    = var.subdomain
  type    = "A"
  value   = var.lb_ip_address
  ttl     = var.ttl
  proxied = var.proxied # Si es true, usa Cloudflare como proxy (recomendado)
  comment = "DNS record for ${var.environment} environment - Managed by Terraform"
}

# Registro CNAME para www (opcional)
resource "cloudflare_record" "dns_cname_www" {
  count   = var.create_www_record ? 1 : 0
  zone_id = var.zone_id
  name    = "www.${var.subdomain}"
  type    = "CNAME"
  value   = var.subdomain
  ttl     = var.ttl
  proxied = var.proxied
  comment = "WWW CNAME for ${var.environment} environment - Managed by Terraform"
}

