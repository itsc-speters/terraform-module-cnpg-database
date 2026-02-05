# Create databases from the list
resource "kubernetes_manifest" "database" {
  for_each   = { for db in local.databases_for_iteration : db.name => db }
  depends_on = [kubernetes_manifest.cluster]

  lifecycle {
    precondition {
      condition     = length([for db in local.databases_for_iteration : db.name]) == length(distinct([for db in local.databases_for_iteration : db.name]))
      error_message = "All database names in var.databases must be unique. Duplicate names would cause a duplicate key error in the for_each map."
    }
  }

  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"
    metadata = {
      name      = each.value.name
      namespace = var.cluster.namespace
      labels    = var.labels
    }
    spec = {
      cluster = {
        name = var.cluster.name
      }
      name                  = each.value.pg_database_name != null && each.value.pg_database_name != "" ? each.value.pg_database_name : replace(each.value.name, "-", "_")
      owner                 = each.value.owner
      databaseReclaimPolicy = each.value.database_reclaim_policy
    }
  }
}
