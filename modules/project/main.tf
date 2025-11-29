# Módulo para gestionar proyectos GCP
# Este módulo puede crear un proyecto nuevo o usar uno existente

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

# Datos del proyecto existente o creación de nuevo
data "google_project" "existing" {
  count      = var.use_existing_project ? 1 : 0
  project_id = var.project_id
}

resource "google_project" "new" {
  count           = var.use_existing_project ? 0 : 1
  name            = var.project_name
  project_id      = var.project_id
  org_id          = var.org_id
  billing_account = var.billing_account_id
  labels          = var.labels
}

# Habilitar APIs necesarias
resource "google_project_service" "apis" {
  for_each = toset(var.required_apis)
  project  = var.use_existing_project ? var.project_id : google_project.new[0].project_id
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

# Tiempo de espera para que las APIs se activen
resource "time_sleep" "wait_for_apis" {
  depends_on = [google_project_service.apis]
  create_duration = "60s"
}

