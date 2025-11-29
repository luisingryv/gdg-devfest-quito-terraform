variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "service_name" {
  description = "Nombre del servicio Cloud Run"
  type        = string
}

variable "region" {
  description = "Región de GCP"
  type        = string
  default     = "us-central1"
}

variable "container_image" {
  description = "Imagen del contenedor (ej: gcr.io/project/image:tag o docker.io/library/nginx:latest)"
  type        = string
}

variable "container_port" {
  description = "Puerto del contenedor"
  type        = number
  default     = 8080
}

variable "min_instances" {
  description = "Número mínimo de instancias (0 para escalar a cero)"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Número máximo de instancias"
  type        = number
  default     = 3
}

variable "cpu_limit" {
  description = "Límite de CPU (ej: '1', '2', '1000m')"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Límite de memoria (ej: '512Mi', '1Gi', '2Gi')"
  type        = string
  default     = "512Mi"
}

variable "timeout_seconds" {
  description = "Timeout de la request en segundos"
  type        = number
  default     = 300
}

variable "environment_variables" {
  description = "Variables de entorno del contenedor"
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Variables de entorno secretas (desde Secret Manager)"
  type = map(object({
    secret_name = string
    version     = string
  }))
  default = {}
}

variable "vpc_connector_name" {
  description = "Nombre del VPC Connector (para conectar a Cloud SQL)"
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "Email de la service account (dejar vacío para crear una nueva)"
  type        = string
  default     = ""
}

variable "lb_service_account_email" {
  description = "Email de la service account del Load Balancer (para IAM)"
  type        = string
  default     = ""
}

variable "cloud_sql_connection_name" {
  description = "Connection name de Cloud SQL (formato: project:region:instance)"
  type        = string
  default     = ""
}

variable "enable_cloud_sql_access" {
  description = "Habilitar acceso a Cloud SQL (usar true si cloud_sql_connection_name está configurado)"
  type        = bool
  default     = false
}

variable "allow_unauthenticated" {
  description = "Permitir invocación sin autenticación (para Load Balancer público)"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Etiquetas para el servicio"
  type        = map(string)
  default     = {}
}

