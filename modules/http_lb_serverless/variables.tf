variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "environment" {
  description = "Entorno (develop, qa, prod)"
  type        = string
}

variable "region" {
  description = "Región de GCP donde están los servicios Cloud Run"
  type        = string
  default     = "us-central1"
}

variable "frontend_service_name" {
  description = "Nombre del servicio Cloud Run del frontend"
  type        = string
}

variable "backend_service_name" {
  description = "Nombre del servicio Cloud Run del backend"
  type        = string
}

variable "ssl_domains" {
  description = "Lista de dominios para el certificado SSL (ej: ['devfest-demo.mydomain.com', '*.devfest-demo.mydomain.com'])"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}

