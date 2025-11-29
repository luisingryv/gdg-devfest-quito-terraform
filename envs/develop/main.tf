# Configuración del entorno de Desarrollo
# Despliega toda la infraestructura para el entorno develop

terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    # cloudflare = {
    #   source  = "cloudflare/cloudflare"
    #   version = "~> 4.0"
    # }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }

  # Backend remoto (comentado por defecto, descomentar para producción)
  # backend "gcs" {
  #   bucket = "terraform-state-devfest"
  #   prefix = "envs/develop"
  # }
}

# Configurar provider de Google
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Configurar provider de Cloudflare (opcional)
# COMENTADO: Se configurará manualmente más adelante
# provider "cloudflare" {
#   api_token = var.cloudflare_api_token != "" ? var.cloudflare_api_token : null
# }

# Labels comunes para todos los recursos
locals {
  common_labels = {
    environment     = "develop"
    project         = "devfest-gcp-workshop"
    owner           = var.owner
    managed_by      = "terraform"
    provisioned_by  = "cursor"
    cost_center     = var.cost_center
  }
}

# Módulo: Proyecto GCP
module "project" {
  source = "../../modules/project"

  project_id          = var.project_id
  project_name        = var.project_name
  use_existing_project = var.use_existing_project
  org_id              = var.org_id
  billing_account_id  = var.billing_account_id
  labels              = local.common_labels
}

# Módulo: Networking
module "networking" {
  source = "../../modules/networking"

  project_id  = module.project.project_id
  environment = "develop"
  region      = var.region
  labels      = local.common_labels

  depends_on = [module.project]
}

# Módulo: Cloud SQL
module "cloud_sql" {
  source = "../../modules/cloud_sql"

  project_id  = module.project.project_id
  environment = "develop"
  region      = var.region
  labels      = local.common_labels

  db_name     = var.db_name
  db_user     = var.db_user
  db_password = var.db_password
  tier        = var.db_tier

  vpc_network_id         = module.networking.vpc_self_link
  vpc_peering_dependency = module.networking.private_vpc_connection_id

  depends_on = [module.networking]
}

# Módulo: Cloud Run - Backend (Strapi)
module "cloud_run_backend" {
  source = "../../modules/cloud_run_service"

  project_id  = module.project.project_id
  service_name = "dev-strapi-api"
  region      = var.region
  labels      = local.common_labels

  container_image = var.backend_image
  container_port  = 1337 # Puerto por defecto de Strapi

  min_instances = var.backend_min_instances
  max_instances = var.backend_max_instances
  cpu_limit     = var.backend_cpu_limit
  memory_limit  = var.backend_memory_limit

  vpc_connector_name        = module.networking.vpc_connector_name
  cloud_sql_connection_name = module.cloud_sql.connection_name
  enable_cloud_sql_access   = true # Habilitar acceso a Cloud SQL

  environment_variables = {
    NODE_ENV      = "development"
    APP_ENV       = "develop"
    DATABASE_URL  = module.cloud_sql.database_url
    HOST          = "0.0.0.0"
    PORT          = "1337"
  }

  depends_on = [module.networking, module.cloud_sql]
}

# Módulo: Cloud Run - Frontend (Next.js)
module "cloud_run_frontend" {
  source = "../../modules/cloud_run_service"

  project_id   = module.project.project_id
  service_name = "dev-next-frontend"
  region       = var.region
  labels       = local.common_labels

  container_image = var.frontend_image
  container_port  = 3000 # Puerto por defecto de Next.js

  min_instances = var.frontend_min_instances
  max_instances = var.frontend_max_instances
  cpu_limit     = var.frontend_cpu_limit
  memory_limit  = var.frontend_memory_limit

  environment_variables = {
    NODE_ENV            = "development"
    APP_ENV             = "develop"
    NEXT_PUBLIC_API_URL = module.cloud_run_backend.service_url
  }

  depends_on = [module.cloud_run_backend]
}

# Módulo: HTTP(S) Load Balancer
module "http_lb" {
  source = "../../modules/http_lb_serverless"

  project_id  = module.project.project_id
  environment = "develop"
  region      = var.region
  labels      = local.common_labels

  frontend_service_name = module.cloud_run_frontend.service_name
  backend_service_name = module.cloud_run_backend.service_name

  ssl_domains = var.domain_name != "" ? [
    "${var.environment_subdomain}.${var.domain_name}",
    "*.${var.environment_subdomain}.${var.domain_name}"
  ] : []

  depends_on = [module.cloud_run_frontend, module.cloud_run_backend]
}

# Módulo: Cloudflare DNS (opcional)
# COMENTADO: Se configurará manualmente más adelante
# module "cloudflare_dns" {
#   count  = var.cloudflare_zone_id != "" && var.domain_name != "" ? 1 : 0
#   source = "../../modules/cloudflare_dns"
#
#   zone_id       = var.cloudflare_zone_id
#   subdomain     = var.domain_name != "" ? "${var.environment_subdomain}.${var.domain_name}" : ""
#   lb_ip_address = module.http_lb.lb_ip_address
#   environment   = "develop"
#   proxied       = var.cloudflare_proxied
#
#   depends_on = [module.http_lb]
# }

