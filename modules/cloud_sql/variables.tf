variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "environment" {
  description = "Entorno (develop, qa, prod)"
  type        = string
}

variable "region" {
  description = "Región de GCP"
  type        = string
  default     = "us-central1"
}

variable "instance_suffix" {
  description = "Sufijo para el nombre de la instancia"
  type        = string
  default     = "primary"
}

variable "database_version" {
  description = "Versión de PostgreSQL"
  type        = string
  default     = "POSTGRES_14"
}

variable "tier" {
  description = "Tier de la instancia (db-f1-micro para dev, db-g1-small para prod)"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "Tipo de disponibilidad (ZONAL o REGIONAL)"
  type        = string
  default     = "ZONAL"
}

variable "disk_size" {
  description = "Tamaño del disco en GB"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Tipo de disco (PD_SSD o PD_HDD)"
  type        = string
  default     = "PD_SSD"
}

variable "backup_enabled" {
  description = "Habilitar backups automáticos"
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "Hora de inicio de backups (HH:MM formato 24h)"
  type        = string
  default     = "03:00"
}

variable "point_in_time_recovery" {
  description = "Habilitar Point-in-Time Recovery"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Protección contra eliminación"
  type        = bool
  default     = false
}

variable "max_connections" {
  description = "Máximo de conexiones"
  type        = string
  default     = "100"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos (dejar vacío para generar automáticamente)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vpc_network_id" {
  description = "ID de la red VPC para acceso privado"
  type        = string
}

variable "vpc_peering_dependency" {
  description = "Dependencia para el peering de VPC (puede ser null)"
  type        = any
  default     = null
}

variable "labels" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}

