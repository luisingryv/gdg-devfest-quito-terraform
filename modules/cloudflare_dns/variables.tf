variable "zone_id" {
  description = "ID de la zona DNS en Cloudflare"
  type        = string
}

variable "subdomain" {
  description = "Subdominio completo (ej: develop.devfest-demo.mydomain.com)"
  type        = string
}

variable "lb_ip_address" {
  description = "IP pública del Load Balancer de GCP"
  type        = string
}

variable "environment" {
  description = "Entorno (develop, qa, prod)"
  type        = string
}

variable "ttl" {
  description = "TTL del registro DNS en segundos (1 = automático si proxied=true)"
  type        = number
  default     = 1
}

variable "proxied" {
  description = "Si es true, Cloudflare actúa como proxy (recomendado para seguridad y CDN)"
  type        = bool
  default     = true
}

variable "create_www_record" {
  description = "Crear registro CNAME para www"
  type        = bool
  default     = false
}

