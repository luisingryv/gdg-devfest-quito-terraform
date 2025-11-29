# Módulo de Cloud SQL
# Crea una instancia de PostgreSQL con acceso privado

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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Generar contraseña aleatoria si no se proporciona
resource "random_password" "db_password" {
  count   = var.db_password == "" ? 1 : 0
  length  = 16
  special = true
}

# Instancia de Cloud SQL (PostgreSQL)
resource "google_sql_database_instance" "main" {
  name             = "${var.environment}-sql-${var.instance_suffix}"
  database_version = var.database_version
  region           = var.region
  project          = var.project_id
  # Nota: labels se configuran dentro de settings en versiones recientes del provider

  settings {
    tier                        = var.tier
    availability_type           = var.availability_type
    deletion_protection_enabled = var.deletion_protection
    disk_size                   = var.disk_size
    disk_type                   = var.disk_type
    user_labels                 = var.labels # Labels van dentro de settings

    # Configuración de backups
    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery
    }

    # Configuración de IP
    ip_configuration {
      ipv4_enabled                                  = false # Sin IP pública
      private_network                               = var.vpc_network_id
      enable_private_path_for_google_cloud_services = true
    }

    # Configuración de flags de base de datos
    database_flags {
      name  = "max_connections"
      value = var.max_connections
    }
  }

  depends_on = [var.vpc_peering_dependency]
}

# Base de datos
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Usuario de la base de datos
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  password = var.db_password != "" ? var.db_password : random_password.db_password[0].result
  project  = var.project_id
}

