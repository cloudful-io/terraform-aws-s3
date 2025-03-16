resource "aws_s3_bucket" "logging_bucket" {
  count = var.create_logging_bucket ? 1 : 0
  bucket = var.logging_bucket_name
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  count  = var.create_logging_bucket ? 1 : 0
  bucket = aws_s3_bucket.logging_bucket[0].id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSLogDeliveryWrite",
        Effect    = "Allow",
        Principal = { Service = "logging.s3.amazonaws.com" },
        Action    = "s3:PutObject",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.logging_bucket[0].id}/*"
      }
    ]
  })
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "s3_website_configuration" {
  count  = var.static_website_hosting ? 1 : 0
  bucket = aws_s3_bucket.secure_bucket.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.secure_bucket.id
  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_policy" "allow_access_from_everyone" {
  count  = var.static_website_hosting ? 1 : 0
  bucket = aws_s3_bucket.secure_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.secure_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.block_public]  # Ensure public access settings are applied first
}

resource "aws_kms_key" "s3_kms_key" {
  count  = var.static_website_hosting ? 0 : 1   # create key only if NOT creating a static website
  description             = "KMS key for S3 encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3_kms_alias" {
  count  = var.static_website_hosting ? 0 : 1   # create key only if NOT creating a static website
  name          = "alias/${var.bucket_name}-s3-kms-key"
  target_key_id = aws_kms_key.s3_kms_key[0].id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_kms_encryption" {
  count  = var.static_website_hosting ? 0 : 1   # create key only if NOT creating a static website
  bucket = aws_s3_bucket.secure_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms_key[0].arn
    }
  }
}

resource "aws_s3_bucket_policy" "https_policy" {
  count  = var.static_website_hosting ? 0 : 1   # Apply policy only if not creating a static website  

  bucket = aws_s3_bucket.secure_bucket.id
  policy = jsonencode({
    Statement = [{
      Effect = "Deny"
      Principal = "*"
      Action = "s3:*"
      Resource = [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      }
    }]
  })
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "object_lock" {
  count  = var.object_lock_enabled ? 1 : 0
  bucket = aws_s3_bucket.secure_bucket.id
  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = var.object_lock_retention
    }
  }
}

resource "aws_s3_bucket_logging" "logging" {
  bucket        = aws_s3_bucket.secure_bucket.id
  target_bucket = var.logging_bucket_name
  target_prefix = "logs/"

  depends_on = [aws_s3_bucket.secure_bucket]  # Ensure S3 bucket is created first

}