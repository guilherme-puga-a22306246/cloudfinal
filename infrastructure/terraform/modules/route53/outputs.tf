output "health_check_id" {
  value = aws_route53_health_check.primary.id
}

output "record_name" {
  value = var.domain_name
}