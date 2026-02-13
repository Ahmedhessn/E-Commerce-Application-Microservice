variable "bucket1_name" {
  description = "Name of the first S3 bucket"
  type       = string
  default     = "s3-bucket-1-ahmedemad"
}

variable "bucket2_name" {
  description = "Name of the second S3 bucket"
  type        = string
  default     = "s3-bucket-2-ahmedemad"
}

variable "environment" {
  description = "Environment tag for the buckets"
  type        = string
  default     = "dev"
}
