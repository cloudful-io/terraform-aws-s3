module "static_website" {
    source                  = "../../"

    bucket_name             = var.bucket_name
    static_website_hosting  = true
    block_public_access     = false
    logging_bucket_name     = "cloudful-logs"
}