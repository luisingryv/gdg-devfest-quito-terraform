output "service_name" {
  description = "Nombre del servicio Cloud Run"
  value       = google_cloud_run_v2_service.service.name
}

output "service_id" {
  description = "ID del servicio Cloud Run"
  value       = google_cloud_run_v2_service.service.id
}

output "service_url" {
  description = "URL del servicio Cloud Run"
  value       = google_cloud_run_v2_service.service.uri
}

output "service_location" {
  description = "Ubicación del servicio"
  value       = google_cloud_run_v2_service.service.location
}

output "service_account_email" {
  description = "Email de la service account del servicio"
  value       = var.service_account_email != "" ? var.service_account_email : google_service_account.cloud_run_sa[0].email
}

