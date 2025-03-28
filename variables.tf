variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "static_website_hosting" {
  description = "Enable or disable static website hosting"
  type        = bool
  default     = false
}

variable "block_public_access" {
  description = "Enable or disable blocking public access to the bucket"
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Enable or disable static website hosting"
  type        = bool
  default     = false
}

variable "enforce_encryption_in_transit" {
  description = "Whether to enforce encryption of data in transit"
  type        = bool
  default     = true
}

variable "object_lock_enabled" {
  description = "Enable or disable object lock for data protection"
  type        = bool
  default     = false
}

variable "object_lock_retention" {
  description = "Number of days to retain objects when object lock is enabled"
  type        = number
  default     = 30
}

variable "logging_bucket_name" {
  description = "The name of the logging bucket where access logs will be stored"
  type        = string
}