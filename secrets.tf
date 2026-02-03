# Create password secrets for each database owner
resource "kubernetes_secret_v1" "database_password" {
  for_each = { for db in var.databases : db.name => db }
  metadata {
    name      = "${each.value.name}-user-password"
    namespace = var.cluster.namespace
    labels = merge(
      var.labels,
      {
        "cnpg.io/reload" = "true"
      }
    )
  }
  type = "kubernetes.io/basic-auth"
  data = {
    username = each.value.owner
    password = each.value.password
  }
}

# Optionally create connection secrets for each database
resource "kubernetes_secret_v1" "connection" {
  for_each   = { for db in var.databases : db.name => db if db.create_connection_secret }
  depends_on = [kubernetes_manifest.database]
  metadata {
    name      = "${each.value.name}-db-connection"
    namespace = each.value.connection_secret_namespace != "" ? each.value.connection_secret_namespace : var.cluster.namespace
    labels    = var.labels
  }
  data = {
    host     = base64encode("${var.cluster.name}-rw.${var.cluster.namespace}.svc.cluster.local")
    port     = base64encode("5432")
    database = base64encode(each.value.pg_database_name != null && each.value.pg_database_name != "" ? each.value.pg_database_name : replace(each.value.name, "-", "_"))
    username = base64encode(each.value.owner)
    password = base64encode(each.value.password)
    uri      = base64encode("postgresql://${each.value.owner}:${each.value.password}@${var.cluster.name}-rw.${var.cluster.namespace}.svc.cluster.local:5432/${each.value.pg_database_name != null && each.value.pg_database_name != "" ? each.value.pg_database_name : replace(each.value.name, "-", "_")}")
  }
}
