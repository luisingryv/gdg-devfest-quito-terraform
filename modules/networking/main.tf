# Módulo de Networking
# Configura VPC, subredes y Serverless VPC Access Connector

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

# Usar VPC por defecto o crear una nueva
data "google_compute_network" "default" {
  count   = var.use_default_vpc ? 1 : 0
  name    = "default"
  project = var.project_id
}

resource "google_compute_network" "vpc" {
  count                   = var.use_default_vpc ? 0 : 1
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
  # Nota: google_compute_network no soporta labels directamente
}

# Subred regional para el VPC Connector
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.environment}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = var.use_default_vpc ? data.google_compute_network.default[0].id : google_compute_network.vpc[0].id
  project       = var.project_id
  # Nota: google_compute_subnetwork no soporta labels directamente

  # Habilitar Private Google Access para Cloud SQL
  private_ip_google_access = true
}

# Serverless VPC Access Connector
# Permite que Cloud Run se conecte a Cloud SQL de forma privada
resource "google_vpc_access_connector" "connector" {
  name          = "${var.environment}-vpc-connector"
  region        = var.region
  project       = var.project_id
  # Nota: Cuando se especifica subnet, no se debe especificar network (se infiere automáticamente)
  subnet {
    name = google_compute_subnetwork.subnet.name
  }
  machine_type   = var.connector_machine_type
  min_instances  = var.connector_min_instances
  max_instances  = var.connector_max_instances
  # Nota: google_vpc_access_connector no soporta labels directamente
}

# Peering de VPC para Cloud SQL (necesario para acceso privado)
# Google crea automáticamente una red de servicios para Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.environment}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.use_default_vpc ? data.google_compute_network.default[0].id : google_compute_network.vpc[0].id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.use_default_vpc ? data.google_compute_network.default[0].id : google_compute_network.vpc[0].id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

