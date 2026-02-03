variable "databases" {
  description = "List of databases to create. Each object must have name, owner, password, and database_reclaim_policy."
  type = list(object({
    name                        = string
    owner                       = string
    password                    = string
    database_reclaim_policy     = optional(string, "retain")
    pg_database_name            = optional(string, "")
    create_connection_secret    = optional(bool, true)
    connection_secret_namespace = optional(string, "")
  }))
  default = []
}

variable "cluster" {
  description = "CloudNative-PG cluster configuration object"
  type = object({
    name                                    = optional(string, "default-cluster")
    namespace                               = optional(string, "default")
    instances                               = optional(number, 1)
    storage_class                           = optional(string, "longhorn")
    storage_size                            = optional(string, "10Gi")
    postgresql_max_connections              = optional(string, "100")
    postgresql_shared_buffers               = optional(string, "256MB")
    postgresql_effective_cache_size         = optional(string, "1GB")
    postgresql_maintenance_work_mem         = optional(string, "64MB")
    postgresql_checkpoint_completion_target = optional(string, "0.9")
    postgresql_wal_buffers                  = optional(string, "16MB")
    postgresql_default_statistics_target    = optional(string, "100")
    postgresql_random_page_cost             = optional(string, "1.1")
    postgresql_effective_io_concurrency     = optional(string, "200")
    postgresql_work_mem                     = optional(string, "2621kB")
    postgresql_min_wal_size                 = optional(string, "512MB")
    postgresql_max_wal_size                 = optional(string, "2GB")
    bootstrap_database                      = optional(string, "postgres")
    bootstrap_owner                         = optional(string, "postgres")
    enable_pod_monitor                      = optional(bool, true)
    resources = optional(object({
      requests = optional(object({
        memory = optional(string, "512Mi")
        cpu    = optional(string, "250m")
      }), {})
      limits = optional(object({
        memory = optional(string, "1Gi")
        cpu    = optional(string, "500m")
      }), {})
    }), {})
  })
  default = {}

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster.name))
    error_message = "Cluster name must be a valid Kubernetes resource name (lowercase alphanumeric with hyphens)."
  }

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster.namespace))
    error_message = "Namespace must be a valid Kubernetes resource name (lowercase alphanumeric with hyphens)."
  }
}

variable "labels" {
  description = "Additional labels to add to all resources"
  type        = map(string)
  default     = {}
}
