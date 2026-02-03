# Create databases from the list
resource "kubernetes_manifest" "database" {
  for_each   = { for db in var.databases : db.name => db }
  depends_on = [kubernetes_manifest.cluster]
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
      databasereclaimpolicy = each.value.databasereclaimpolicy
    }
  }
}
