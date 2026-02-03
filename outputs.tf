
output "database_names" {
  description = "Names of the created databases in PostgreSQL"
  value       = [for db in var.databases : db.pg_database_name != null && db.pg_database_name != "" ? db.pg_database_name : replace(db.name, "-", "_")]
  sensitive   = true
}

output "owner_usernames" {
  description = "Usernames of the database owners"
  value       = [for db in var.databases : db.owner]
  sensitive   = true
}

output "password_secret_names" {
  description = "Names of the Kubernetes secrets containing the database passwords"
  value       = [for s in kubernetes_secret_v1.database_password : s.metadata[0].name]
}

output "connection_secret_names" {
  description = "Names of the Kubernetes secrets containing connection details"
  value       = [for s in kubernetes_secret_v1.connection : s.metadata[0].name]
}

output "connection_host" {
  description = "Database connection hostname"
  value       = "${var.cluster.name}-rw.${var.cluster.namespace}.svc.cluster.local"
}

output "connection_port" {
  description = "Database connection port"
  value       = "5432"
}

output "connection_uris" {
  description = "Full PostgreSQL connection URIs for each database"
  value       = [for db in var.databases : "postgresql://${db.owner}:${db.password}@${var.cluster.name}-rw.${var.cluster.namespace}.svc.cluster.local:5432/${db.pg_database_name != null && db.pg_database_name != "" ? db.pg_database_name : replace(db.name, "-", "_")}"]
  sensitive   = true
}
