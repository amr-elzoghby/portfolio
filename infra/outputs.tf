# infra/outputs.tf

output "s3_website_url" {
  value = aws_s3_bucket_website_configuration.portfolio.website_endpoint
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.portfolio.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.portfolio.id
}
