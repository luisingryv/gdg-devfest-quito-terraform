# Módulo de HTTP(S) Load Balancer para servicios serverless (Cloud Run)
# Usa Serverless NEGs para conectar con Cloud Run

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

# Reservar IP estática global
resource "google_compute_global_address" "lb_ip" {
  name         = "${var.environment}-lb-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  # Nota: google_compute_global_address no soporta labels directamente
}

# Serverless NEG para Frontend (Next.js)
resource "google_compute_region_network_endpoint_group" "frontend_neg" {
  name                  = "${var.environment}-frontend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id
  cloud_run {
    service = var.frontend_service_name
  }
  # Nota: google_compute_region_network_endpoint_group no soporta labels directamente
}

# Serverless NEG para Backend (Strapi)
resource "google_compute_region_network_endpoint_group" "backend_neg" {
  name                  = "${var.environment}-backend-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id
  cloud_run {
    service = var.backend_service_name
  }
  # Nota: google_compute_region_network_endpoint_group no soporta labels directamente
}

# Backend Service para Frontend
resource "google_compute_backend_service" "frontend_backend" {
  name                  = "${var.environment}-frontend-backend"
  project               = var.project_id
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = false
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.frontend_neg.id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  # Nota: google_compute_backend_service no soporta labels directamente
}

# Backend Service para Backend
resource "google_compute_backend_service" "backend_backend" {
  name                  = "${var.environment}-backend-backend"
  project               = var.project_id
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = false
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.backend_neg.id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  # Nota: google_compute_backend_service no soporta labels directamente
}

# URL Map - Routing rules
resource "google_compute_url_map" "url_map" {
  name            = "${var.environment}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.frontend_backend.id

  # Routing: /api/* → Backend
  host_rule {
    hosts        = ["*"]
    path_matcher = "api-routes"
  }

  path_matcher {
    name            = "api-routes"
    default_service = google_compute_backend_service.frontend_backend.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.backend_backend.id
    }
  }

  # Nota: google_compute_url_map no soporta labels directamente
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.environment}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.url_map.id
  # Nota: google_compute_target_http_proxy no soporta labels directamente
}

# HTTPS Proxy (con certificado SSL)
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.environment}-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.id]
  # Nota: google_compute_target_https_proxy no soporta labels directamente
}

# Certificado SSL gestionado por Google
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name    = "${var.environment}-ssl-cert"
  project = var.project_id
  # Nota: google_compute_managed_ssl_certificate no soporta labels directamente

  managed {
    domains = var.ssl_domains
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Forwarding Rule HTTP (redirige a HTTPS)
resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.environment}-http-forwarding-rule"
  project    = var.project_id
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.address
  # Nota: google_compute_global_forwarding_rule no soporta labels directamente
}

# Forwarding Rule HTTPS
resource "google_compute_global_forwarding_rule" "https" {
  name       = "${var.environment}-https-forwarding-rule"
  project    = var.project_id
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.lb_ip.address
  # Nota: google_compute_global_forwarding_rule no soporta labels directamente
}

