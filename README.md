# Terraform Module: CloudNative-PG Database

Terraform module for creating PostgreSQL databases in CloudNative-PG clusters with automatic user and secret management.

## Features

- 🔐 Automatic password secret creation with hot-reload support
- 📦 Database and user provisioned declaratively
- 🔌 Connection details secret for easy application integration
- 🏷️ Customizable labels for all resources
- ✅ Input validation for security best practices

## Prerequisites

- CloudNative-PG operator installed in your Kubernetes cluster
- An existing CloudNative-PG Cluster resource
- The cluster must have the database user defined in `spec.managed.roles`

## Usage

### Basic Example

```hcl
module "my_app_database" {
  source = "github.com/pascalinthecloud/terraform-module-cnpg-database"

  database = {
    name           = "my-app"
    owner_username = "my_app_user"
    password       = var.database_password # Use a secure variable or secret manager
  }

  cluster = {
    name      = "shared-postgres-prod"
    namespace = "databases-prod"
  }
}
```

### Complete Example with Labels

```hcl
module "my_app_database" {
  source = "github.com/pascalinthecloud/terraform-module-cnpg-database"

  database = {
    name           = "my-app"
    owner_username = "my_app_user"
    password       = var.database_password
  }

  cluster = {
    name      = "shared-postgres-prod"
    namespace = "databases-prod"
  }

  labels = {
    app         = "my-app"
    environment = "production"
    managed-by  = "terraform"
  }
}
```

### Custom PostgreSQL Database Name

```hcl
module "my_app_database" {
  source = "github.com/pascalinthecloud/terraform-module-cnpg-database"

  database = {
    name             = "my-app"
    pg_database_name = "myapp_production" # Custom PostgreSQL database name
    owner_username   = "my_app_user"
    password         = var.database_password
  }

  cluster = {
    name      = "shared-postgres-prod"
    namespace = "databases-prod"
  }
}
```

### Connection Secret in Different Namespace

```hcl
module "my_app_database" {
  source = "github.com/pascalinthecloud/terraform-module-cnpg-database"

  database = {
    name           = "my-app"
    owner_username = "my_app_user"
    password       = var.database_password
  }

  cluster = {
    name      = "shared-postgres-prod"
    namespace = "databases-prod"
  }

  connection_secret_namespace = "my-app-namespace" # Deploy connection secret to app namespace
}
```

## Cluster Configuration

The CloudNative-PG cluster **must** have the database user defined in `spec.managed.roles`:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: shared-postgres-prod
  namespace: databases-prod
spec:
  instances: 3
  managed:
    roles:
      - name: my_app_user
        ensure: present
        login: true
        inherit: true
        passwordSecret:
          name: my-app-user-password  # Created by this module
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.database](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_secret_v1.connection](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.database_password](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | CloudNative-PG cluster configuration object | <pre>object({<br/>    name      = string<br/>    namespace = string<br/>  })</pre> | n/a | yes |
| <a name="input_connection_secret_namespace"></a> [connection\_secret\_namespace](#input\_connection\_secret\_namespace) | Namespace to create the connection secret in (defaults to the database namespace) | `string` | `""` | no |
| <a name="input_create_connection_secret"></a> [create\_connection\_secret](#input\_create\_connection\_secret) | Whether to create a connection details secret for applications | `bool` | `true` | no |
| <a name="input_database"></a> [database](#input\_database) | Database configuration object | <pre>object({<br/>    name             = string<br/>    pg_database_name = optional(string, "")<br/>    owner_username   = string<br/>    password         = string<br/>  })</pre> | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Additional labels to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_host"></a> [connection\_host](#output\_connection\_host) | Database connection hostname |
| <a name="output_connection_port"></a> [connection\_port](#output\_connection\_port) | Database connection port |
| <a name="output_connection_secret_name"></a> [connection\_secret\_name](#output\_connection\_secret\_name) | Name of the Kubernetes secret containing connection details |
| <a name="output_connection_uri"></a> [connection\_uri](#output\_connection\_uri) | Full PostgreSQL connection URI |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Name of the created database in PostgreSQL |
| <a name="output_owner_username"></a> [owner\_username](#output\_owner\_username) | Username of the database owner |
| <a name="output_password_secret_name"></a> [password\_secret\_name](#output\_password\_secret\_name) | Name of the Kubernetes secret containing the database password |
<!-- END_TF_DOCS -->

## Connection Details Secret

When `create_connection_secret = true` (default), the module creates a secret with the following keys:

- `host` - Database hostname
- `port` - Database port (5432)
- `database` - Database name
- `username` - Database username
- `password` - Database password
- `uri` - Full connection URI

Example usage in a pod:

```yaml
env:
  - name: DATABASE_HOST
    valueFrom:
      secretKeyRef:
        name: my-app-db-connection
        key: host
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: my-app-db-connection
        key: uri
```

## How It Works

1. **Password Secret**: Creates a `kubernetes.io/basic-auth` secret with the `cnpg.io/reload` label for hot password updates
2. **Database CRD**: Creates a CloudNative-PG Database resource that triggers database creation
3. **Connection Secret**: Optionally creates a connection details secret for application use

The CloudNative-PG operator reconciles the managed role in the cluster and creates the database with the specified owner.

## Security Best Practices

- Always use a secure method to provide passwords (e.g., Terraform variables with encryption, secret managers)
- Never commit passwords to version control
- Use strong passwords (minimum 8 characters enforced by validation)
- Consider using Kubernetes RBAC to restrict access to password secrets

## License

MIT

## Author

Pascal Toepke
