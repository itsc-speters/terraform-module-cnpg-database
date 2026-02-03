# Basic example of using the CloudNative-PG database module

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

# Configure providers (adjust to your environment)
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create cluster and databases using the module
module "example_app_database" {
  source = "../.."

  databases = [
    {
      name                        = "example-app"
      owner                       = "example_app_user"
      password                    = var.database_password
      database_reclaim_policy     = "retain"
      create_connection_secret    = true
      connection_secret_namespace = ""
    }
  ]

  cluster = {
    name                       = "shared-postgres-dev"
    namespace                  = "databases-dev"
    instances                  = 1
    storage_class              = "longhorn"
    storage_size               = "10Gi"
    postgresql_max_connections = "100"
    # Other PostgreSQL parameters use defaults
  }

  labels = {
    app         = "example-app"
    environment = "dev"
    managed-by  = "terraform"
  }
}

# Output connection details
output "connection_host" {
  description = "Database connection hostname"
  value       = module.example_app_database.connection_host
}

output "connection_port" {
  description = "Database connection port"
  value       = module.example_app_database.connection_port
}

output "database_names" {
  description = "Names of the created databases"
  value       = module.example_app_database.database_names
}

output "connection_secret_names" {
  description = "Names of the connection secrets"
  value       = module.example_app_database.connection_secret_names
}

output "connection_uris" {
  description = "Full PostgreSQL connection URIs"
  value       = module.example_app_database.connection_uris
  sensitive   = true
}
