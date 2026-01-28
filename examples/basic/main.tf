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

# Create a database using the module
module "example_app_database" {
  source = "../.."

  database = {
    name           = "example-app"
    owner_username = "example_app_user"
    password       = var.database_password
  }

  cluster = {
    name      = "shared-postgres-prod"
    namespace = "databases-prod"
  }

  labels = {
    app        = "example-app"
    managed-by = "terraform"
  }
}

# Output connection details
output "connection_host" {
  description = "Database connection hostname"
  value       = module.example_app_database.connection_host
}

output "connection_secret" {
  description = "Name of the connection secret"
  value       = module.example_app_database.connection_secret_name
}
