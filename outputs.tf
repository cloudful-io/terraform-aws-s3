output "id" {
  description = "The name of the created S3 bucket."
  value       = aws_s3_bucket.secure_bucket.id
}

output "arn" { 
  description = "The Amazon Resource Name (ARN) of the created S3 bucket."
  value       = aws_s3_bucket.secure_bucket.arn
} 

output "region" { 
  description = "The region of the created S3 bucket."
  value       = aws_s3_bucket.secure_bucket.region
} 