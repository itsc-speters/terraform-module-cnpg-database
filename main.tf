# Password secret for the database user
# This must exist before the cluster reconciles the managed role
resource "kubernetes_secret_v1" "database_password" {
  metadata {
    name      = "${var.database.name}-user-password"
    namespace = var.cluster.namespace
    labels = merge(
      var.labels,
      {
        "cnpg.io/reload" = "true" # Enable hot reload of password changes
      }
    )
  }

  type = "kubernetes.io/basic-auth"

  data = {
    username = var.database.owner_username
    password = var.database.password
  }
}

# Database resource in CloudNative-PG
# Creates the actual PostgreSQL database
resource "kubernetes_manifest" "database" {
  depends_on = [kubernetes_secret_v1.database_password]

  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = var.database.name
      namespace = var.cluster.namespace
      labels    = var.labels
    }
    spec = {
      cluster = {
        name = var.cluster.name
      }
      name  = var.database.pg_database_name != "" ? var.database.pg_database_name : replace(var.database.name, "-", "_")
      owner = var.database.owner_username
    }
  }
}

# Connection details secret for application consumption
# Contains all necessary information to connect to the database
resource "kubernetes_secret_v1" "connection" {
  count = var.create_connection_secret ? 1 : 0

  depends_on = [kubernetes_manifest.database]

  metadata {
    name      = "${var.database.name}-db-connection"
    namespace = var.connection_secret_namespace != "" ? var.connection_secret_namespace : var.cluster.namespace
    labels    = var.labels
  }

  data = {
    host     = base64encode("${var.cluster.name}-rw.${var.cluster.namespace}.svc.cluster.local")
    port     = base64encode("5432")
    database = base64encode(var.database.pg_database_name != "" ? var.database.pg_database_name : replace(var.database.name, "-", "_"))
    username = base64encode(var.database.owner_username)
    password = base64encode(var.database.password)
    uri      = base64encode("postgresql://${var.database.owner_username}:${var.database.password}@${var.cluster.name}-rw.${var.cluster.namespace}.svc.cluster.local:5432/${var.database.pg_database_name != "" ? var.database.pg_database_name : replace(var.database.name, "-", "_")}")
  }
}
