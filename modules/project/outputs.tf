output "project_id" {
  description = "ID del proyecto GCP"
  value       = var.use_existing_project ? var.project_id : google_project.new[0].project_id
}

output "project_number" {
  description = "Número del proyecto GCP"
  value       = var.use_existing_project ? data.google_project.existing[0].number : google_project.new[0].number
}

