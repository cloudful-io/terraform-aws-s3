output "url" {
  description = "URL of static website"
  value       = "http://${module.static_website.id}.s3-website-${module.static_website.region}.amazonaws.com"
}