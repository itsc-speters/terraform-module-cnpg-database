# Create the PostgreSQL cluster with managed roles
resource "kubernetes_manifest" "cluster" {
  depends_on = length(var.databases) > 0 ? [kubernetes_secret_v1.database_password] : []

  # Ignore server-side defaults added by CNPG operator
  computed_fields = [
    "spec.postgresql.parameters",
  ]

  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = var.cluster.name
      namespace = var.cluster.namespace
      labels    = var.labels
    }
    spec = {
      instances = var.cluster.instances

      # Storage using configurable storage class
      storage = {
        storageClass = var.cluster.storage_class
        size         = var.cluster.storage_size
      }

      # PostgreSQL configuration
      postgresql = {
        parameters = {
          max_connections              = var.cluster.postgresql_max_connections
          shared_buffers               = var.cluster.postgresql_shared_buffers
          effective_cache_size         = var.cluster.postgresql_effective_cache_size
          maintenance_work_mem         = var.cluster.postgresql_maintenance_work_mem
          checkpoint_completion_target = var.cluster.postgresql_checkpoint_completion_target
          wal_buffers                  = var.cluster.postgresql_wal_buffers
          default_statistics_target    = var.cluster.postgresql_default_statistics_target
          random_page_cost             = var.cluster.postgresql_random_page_cost
          effective_io_concurrency     = var.cluster.postgresql_effective_io_concurrency
          work_mem                     = var.cluster.postgresql_work_mem
          min_wal_size                 = var.cluster.postgresql_min_wal_size
          max_wal_size                 = var.cluster.postgresql_max_wal_size
        }
      }

      # Bootstrap
      bootstrap = {
        initdb = {
          database = var.cluster.bootstrap_database
          owner    = var.cluster.bootstrap_owner
        }
      }

      # Monitoring
      monitoring = {
        enablePodMonitor = var.cluster.enable_pod_monitor
      }

      # Resources
      resources = var.cluster.resources

      # Managed roles - define users based on distinct database owners
      managed = {
        roles = [for owner in distinct([for db in var.databases : db.owner]) : {
          name    = owner
          ensure  = "present"
          login   = true
          inherit = true
          passwordSecret = {
            # Use the first database name associated with this owner
            name = "${element([for db in var.databases : db.name if db.owner == owner], 0)}-user-password"
          }
        }]
      }

      # Backup configuration (conditional based on backup.enabled)
      backup = var.backup.enabled ? {
        barmanObjectStore = {
          # S3 destination
          destinationPath = "s3://${var.backup.s3_bucket_name}/"
          endpointURL     = var.backup.s3_endpoint_url != "" ? var.backup.s3_endpoint_url : null
          serverName      = var.cluster.name

          # S3 credentials reference
          s3Credentials = {
            accessKeyId = {
              name = kubernetes_secret_v1.backup_credentials[0].metadata[0].name
              key  = "ACCESS_KEY_ID"
            }
            secretAccessKey = {
              name = kubernetes_secret_v1.backup_credentials[0].metadata[0].name
              key  = "ACCESS_SECRET_KEY"
            }
          }

          # WAL (Write-Ahead Log) configuration
          wal = {
            compression = var.backup.wal_compression
            # WAL upload parallelism is intentionally limited to 2 to avoid excessive I/O/CPU pressure
            # and to follow CNPG/Barman recommendations. Data backup parallelism is configured separately
            # via var.backup.jobs in the "data" block below.
            maxParallel = 2
          }

          # Data backup configuration
          data = {
            compression         = var.backup.data_compression
            jobs                = var.backup.jobs
            immediateCheckpoint = false
          }
        }

        # Retention policy
        retentionPolicy = var.backup.retention_policy

        # Backup target
        target = var.backup.target
      } : null
    }
  }
}
