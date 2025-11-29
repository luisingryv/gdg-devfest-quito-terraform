variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto GCP"
  type        = string
  default     = ""
}

variable "use_existing_project" {
  description = "Si es true, usa un proyecto existente. Si es false, crea uno nuevo."
  type        = bool
  default     = true
}

variable "org_id" {
  description = "ID de la organización GCP (opcional, solo si se crea proyecto nuevo)"
  type        = string
  default     = ""
}

variable "billing_account_id" {
  description = "ID de la cuenta de facturación (requerido si se crea proyecto nuevo)"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Etiquetas para el proyecto"
  type        = map(string)
  default     = {}
}

variable "required_apis" {
  description = "Lista de APIs que deben estar habilitadas"
  type        = list(string)
  default = [
    "run.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "vpcaccess.googleapis.com", # Para Serverless VPC Access
  ]
}

