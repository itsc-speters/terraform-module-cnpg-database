variable "database_password" {
  description = "Password for the database user"
  type        = string
  sensitive   = true
}

# Backup configuration (optional - only needed if backup is enabled)
variable "backup_enabled" {
  description = "Enable S3 backups for the cluster"
  type        = bool
  default     = false
}

variable "s3_endpoint_url" {
  description = "S3 endpoint URL for backups (leave empty for AWS S3)"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "S3 bucket name for backups"
  type        = string
  default     = ""
}

variable "s3_access_key_id" {
  description = "S3 access key ID for backups"
  type        = string
  sensitive   = true
  default     = ""
}

variable "s3_secret_access_key" {
  description = "S3 secret access key for backups"
  type        = string
  sensitive   = true
  default     = ""
}
