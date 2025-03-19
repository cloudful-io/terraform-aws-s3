module "secured-bucket" {
    source                  = "../../"

    bucket_name             = var.bucket_name
    static_website_hosting  = false
    block_public_access     = true
    create_kms_key          = false
    create_logging_bucket   = true
    logging_bucket_name     = "cloudful-logs"
}