output "url" {
  description = "URL of static website"
  value       = "http://${module.static_website.bucket_name}.s3-website-${module.static_website.region}.amazonaws.com"
}