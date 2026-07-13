output "central_health_check_id" {
  value = aws_route53_health_check.central.id
}

output "west_health_check_id" {
  value = aws_route53_health_check.west.id
}

output "record_name" {
  value = var.domain_name
}