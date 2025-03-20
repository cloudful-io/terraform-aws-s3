module "hub-bucket" {
    source                  = "../../"

    bucket_name             = var.hub_bucket_name
    static_website_hosting  = false
    block_public_access     = true
    create_kms_key          = false
    create_logging_bucket   = true
    logging_bucket_name     = "cloudful-logs"
}

module "spoke1-bucket" {
    source                  = "../../"

    bucket_name             = var.spoke1_bucket_name
    static_website_hosting  = false
    block_public_access     = true
    create_kms_key          = false
    create_logging_bucket   = false
    logging_bucket_name     = "cloudful-logs"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name               = "tf-iam-role-replication-hub-spoke"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [module.spoke1-bucket.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${module.spoke1-bucket.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${module.hub-bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  name   = "tf-iam-role-policy-replication-hub-spoke"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket_ownership_controls" "spoke1_bucket_ownership" {
  bucket = module.spoke1-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "spoke1_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.spoke1_bucket_ownership]
  bucket = module.spoke1-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  
  role   = aws_iam_role.replication.arn
  bucket = module.spoke1-bucket.id

  rule {
    id = "foobar"

    filter {
      prefix = "foo"
    }

    delete_marker_replication {
      status = "Enabled"
    }

    status = "Enabled"

    destination {
      bucket        = module.hub-bucket.arn
      storage_class = "STANDARD"
    }
  }
}