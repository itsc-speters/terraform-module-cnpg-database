variable "database" {
  description = "Database configuration object"
  type = object({
    name             = string
    pg_database_name = optional(string, "")
    owner_username   = string
    password         = string
  })
  sensitive = true

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.database.name))
    error_message = "Database name must be a valid Kubernetes resource name (lowercase alphanumeric with hyphens)."
  }

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_]*$", var.database.owner_username))
    error_message = "Owner username must be a valid PostgreSQL identifier (lowercase alphanumeric and underscores, starting with letter or underscore)."
  }

  validation {
    condition     = length(var.database.password) >= 8
    error_message = "Password must be at least 8 characters long."
  }
}

variable "cluster" {
  description = "CloudNative-PG cluster configuration object"
  type = object({
    name      = string
    namespace = string
  })

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster.name))
    error_message = "Cluster name must be a valid Kubernetes resource name (lowercase alphanumeric with hyphens)."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster.namespace))
    error_message = "Namespace must be a valid Kubernetes resource name (lowercase alphanumeric with hyphens)."
  }
}

variable "create_connection_secret" {
  description = "Whether to create a connection details secret for applications"
  type        = bool
  default     = true
}

variable "connection_secret_namespace" {
  description = "Namespace to create the connection secret in (defaults to the database namespace)"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Additional labels to add to all resources"
  type        = map(string)
  default     = {}
}
