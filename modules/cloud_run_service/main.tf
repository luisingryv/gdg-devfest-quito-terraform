# Módulo genérico de Cloud Run Service
# Puede usarse para backend (Strapi) o frontend (Next.js)

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

# Service Account para Cloud Run (opcional, usa default si no se especifica)
resource "google_service_account" "cloud_run_sa" {
  count        = var.service_account_email == "" ? 1 : 0
  account_id   = "${var.service_name}-sa"
  display_name = "Service Account for ${var.service_name}"
  project      = var.project_id
}

# Permisos para Cloud SQL si se necesita
resource "google_project_iam_member" "cloud_sql_client" {
  count   = var.cloud_sql_connection_name != "" ? 1 : 0
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${var.service_account_email != "" ? var.service_account_email : google_service_account.cloud_run_sa[0].email}"
}

# Servicio de Cloud Run
resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.region
  project  = var.project_id
  labels   = var.labels

  template {
    # Configuración de escalado
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # Configuración de contenedor
    containers {
      image = var.container_image

      # Variables de entorno
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      # Variables de entorno secretas (si se usan)
      dynamic "env" {
        for_each = var.secret_environment_variables
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value.secret_name
              version = env.value.version
            }
          }
        }
      }

      # Recursos
      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      # Puerto
      ports {
        container_port = var.container_port
      }
    }

    # Service Account
    service_account = var.service_account_email != "" ? var.service_account_email : google_service_account.cloud_run_sa[0].email

    # VPC Connector (para conectar a Cloud SQL)
    vpc_access {
      connector = var.vpc_connector_name != "" ? var.vpc_connector_name : null
      egress    = var.vpc_connector_name != "" ? "PRIVATE_RANGES_ONLY" : "ALL_TRAFFIC"
    }

    # Timeout
    timeout = var.timeout_seconds
  }

  # Tráfico
  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

# IAM: Permitir invocación pública o desde Load Balancer
resource "google_cloud_run_service_iam_member" "public_access" {
  count    = var.allow_unauthenticated ? 1 : 0
  service  = google_cloud_run_v2_service.service.name
  location = google_cloud_run_v2_service.service.location
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# IAM: Permitir invocación desde Load Balancer (service account del LB)
resource "google_cloud_run_service_iam_member" "lb_access" {
  count    = var.lb_service_account_email != "" ? 1 : 0
  service  = google_cloud_run_v2_service.service.name
  location = google_cloud_run_v2_service.service.location
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.lb_service_account_email}"
}

