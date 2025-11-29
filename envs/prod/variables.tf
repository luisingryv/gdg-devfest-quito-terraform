variable "project_id" {
  description = "ID del proyecto GCP para producción"
  type        = string
  default     = "myapp-prod"
}

variable "project_name" {
  description = "Nombre del proyecto GCP (solo si se crea nuevo)"
  type        = string
  default     = "DevFest Production"
}

variable "use_existing_project" {
  description = "Usar un proyecto existente (true) o crear uno nuevo (false)"
  type        = bool
  default     = true
}

variable "org_id" {
  description = "ID de la organización GCP (opcional)"
  type        = string
  default     = ""
}

variable "billing_account_id" {
  description = "ID de la cuenta de facturación"
  type        = string
  default     = ""
}

variable "region" {
  description = "Región de GCP"
  type        = string
  default     = "us-central1"
}

variable "owner" {
  description = "Propietario del proyecto (para labels)"
  type        = string
  default     = "devfest-team"
}

variable "cost_center" {
  description = "Centro de costos (opcional)"
  type        = string
  default     = ""
}

# Base de datos
variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "strapi_db"
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "strapi_user"
}

variable "db_password" {
  description = "Contraseña de la base de datos (OBLIGATORIO usar secretos en producción)"
  type        = string
  sensitive   = true
  # NO proporcionar default en producción
}

variable "db_tier" {
  description = "Tier de la instancia de Cloud SQL"
  type        = string
  default     = "db-g1-small" # Tier más grande para producción
}

variable "db_availability_type" {
  description = "Tipo de disponibilidad (ZONAL o REGIONAL para HA)"
  type        = string
  default     = "REGIONAL" # Alta disponibilidad en producción
}

# Cloud Run - Backend
variable "backend_image" {
  description = "Imagen del contenedor del backend (Strapi)"
  type        = string
  default     = "strapi/strapi:latest" # Placeholder, usar imagen real
}

variable "backend_min_instances" {
  description = "Mínimo de instancias del backend"
  type        = number
  default     = 1 # Mínimo 1 en producción para evitar cold starts
}

variable "backend_max_instances" {
  description = "Máximo de instancias del backend"
  type        = number
  default     = 10
}

variable "backend_cpu_limit" {
  description = "Límite de CPU del backend"
  type        = string
  default     = "2"
}

variable "backend_memory_limit" {
  description = "Límite de memoria del backend"
  type        = string
  default     = "2Gi"
}

# Cloud Run - Frontend
variable "frontend_image" {
  description = "Imagen del contenedor del frontend (Next.js)"
  type        = string
  default     = "node:18-alpine" # Placeholder, usar imagen real
}

variable "frontend_min_instances" {
  description = "Mínimo de instancias del frontend"
  type        = number
  default     = 1 # Mínimo 1 en producción
}

variable "frontend_max_instances" {
  description = "Máximo de instancias del frontend"
  type        = number
  default     = 10
}

variable "frontend_cpu_limit" {
  description = "Límite de CPU del frontend"
  type        = string
  default     = "2"
}

variable "frontend_memory_limit" {
  description = "Límite de memoria del frontend"
  type        = string
  default     = "2Gi"
}

# DNS y Cloudflare
variable "domain_name" {
  description = "Dominio base (ej: devfest-demo.mydomain.com)"
  type        = string
  default     = ""
}

variable "environment_subdomain" {
  description = "Subdominio del entorno (ej: develop, qa, prod)"
  type        = string
  default     = "prod"
}

variable "cloudflare_zone_id" {
  description = "ID de la zona DNS en Cloudflare (opcional)"
  type        = string
  default     = ""
}

variable "cloudflare_api_token" {
  description = "Token de API de Cloudflare (opcional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_proxied" {
  description = "Usar Cloudflare como proxy (recomendado)"
  type        = bool
  default     = true
}

