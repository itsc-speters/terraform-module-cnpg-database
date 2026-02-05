locals {
  # Create a non-sensitive version of databases for use in for_each
  # This is required because for_each keys cannot be sensitive values
  # Note: The passwords remain sensitive when used in the secret data blocks
  databases_for_iteration = nonsensitive(var.databases)
}
