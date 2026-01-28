output "database_name" {
  description = "Name of the created database in PostgreSQL"
  value       = var.database.pg_database_name != "" ? var.database.pg_database_name : replace(var.database.name, "-", "_")
  sensitive   = true
}

output "owner_username" {
  description = "Username of the database owner"
  value       = var.database.owner_username
  sensitive   = true
}

output "password_secret_name" {
  description = "Name of the Kubernetes secret containing the database password"
  value       = kubernetes_secret_v1.database_password.metadata[0].name
}

output "connection_secret_name" {
  description = "Name of the Kubernetes secret containing connection details"
  value       = var.create_connection_secret ? kubernetes_secret_v1.connection[0].metadata[0].name : null
}

output "connection_host" {
  description = "Database connection hostname"
  value       = "${var.cluster.name}-rw.${var.cluster.namespace}.svc.cluster.local"
}

output "connection_port" {
  description = "Database connection port"
  value       = "5432"
}

output "connection_uri" {
  description = "Full PostgreSQL connection URI"
  value       = "postgresql://${var.database.owner_username}:${var.database.password}@${var.cluster.name}-rw.${var.cluster.namespace}.svc.cluster.local:5432/${var.database.pg_database_name != "" ? var.database.pg_database_name : replace(var.database.name, "-", "_")}"
  sensitive   = true
}
