output "instance_name" {
  description = "Nombre de la instancia de Cloud SQL"
  value       = google_sql_database_instance.main.name
}

output "connection_name" {
  description = "Connection name para usar en Cloud Run (formato: project:region:instance)"
  value       = google_sql_database_instance.main.connection_name
}

output "private_ip_address" {
  description = "IP privada de la instancia"
  value       = google_sql_database_instance.main.private_ip_address
}

output "database_name" {
  description = "Nombre de la base de datos"
  value       = google_sql_database.database.name
}

output "database_user" {
  description = "Usuario de la base de datos"
  value       = google_sql_user.user.name
}

output "database_password" {
  description = "Contraseña de la base de datos (sensible)"
  value       = var.db_password != "" ? var.db_password : random_password.db_password[0].result
  sensitive   = true
}

output "database_url" {
  description = "URL de conexión a la base de datos (formato PostgreSQL)"
  value       = "postgresql://${google_sql_user.user.name}:${var.db_password != "" ? var.db_password : random_password.db_password[0].result}@${google_sql_database_instance.main.private_ip_address}:5432/${google_sql_database.database.name}"
  sensitive   = true
}

