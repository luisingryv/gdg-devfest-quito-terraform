output "vpc_id" {
  description = "ID de la VPC"
  value       = var.use_default_vpc ? data.google_compute_network.default[0].id : google_compute_network.vpc[0].id
}

output "vpc_self_link" {
  description = "Self link de la VPC (para Cloud SQL)"
  value       = var.use_default_vpc ? data.google_compute_network.default[0].self_link : google_compute_network.vpc[0].self_link
}

output "vpc_name" {
  description = "Nombre de la VPC"
  value       = var.use_default_vpc ? data.google_compute_network.default[0].name : google_compute_network.vpc[0].name
}

output "subnet_self_link" {
  description = "Self link de la subred"
  value       = google_compute_subnetwork.subnet.self_link
}

output "subnet_name" {
  description = "Nombre de la subred"
  value       = google_compute_subnetwork.subnet.name
}

output "vpc_connector_name" {
  description = "Nombre del VPC Access Connector (para usar en Cloud Run)"
  value       = google_vpc_access_connector.connector.name
}

output "vpc_connector_id" {
  description = "ID completo del VPC Access Connector"
  value       = google_vpc_access_connector.connector.id
}

output "private_vpc_connection_id" {
  description = "ID de la conexión de peering privado (para Cloud SQL)"
  value       = google_service_networking_connection.private_vpc_connection.id
}

