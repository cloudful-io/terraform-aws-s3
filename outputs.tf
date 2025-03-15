output "bucket_name" {
  description = "The name of the created S3 bucket."
  value       = aws_s3_bucket.secure_bucket.id
}

output "region" {
  description = "The region of the created S3 bucket."
  value       = aws_s3_bucket.secure_bucket.region
} 