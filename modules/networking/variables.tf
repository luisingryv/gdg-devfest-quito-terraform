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

variable "use_default_vpc" {
  description = "Usar la VPC por defecto del proyecto"
  type        = bool
  default     = true
}

variable "subnet_cidr" {
  description = "CIDR de la subred para el VPC Connector"
  type        = string
  default     = "10.8.0.0/28"
}

variable "connector_machine_type" {
  description = "Tipo de máquina para el VPC Connector"
  type        = string
  default     = "e2-micro"
}

variable "connector_min_instances" {
  description = "Mínimo de instancias del VPC Connector"
  type        = number
  default     = 2
}

variable "connector_max_instances" {
  description = "Máximo de instancias del VPC Connector"
  type        = number
  default     = 3
}

variable "labels" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}

