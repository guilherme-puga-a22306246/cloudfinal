output "vpc_id" {
  value = module.primary.vpc_id
}

output "public_subnet_ids" {
  value = module.primary.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.primary.private_subnet_ids
}

output "instance_id" {
  value = module.primary.instance_id
}

output "instance_public_ip" {
  value = module.primary.instance_public_ip
}

output "app_security_group_id" {
  value = module.primary.app_security_group_id
}

output "product_events_queue_url" {
  value = module.primary.product_events_queue_url
}

output "product_events_queue_arn" {
  value = module.primary.product_events_queue_arn
}

output "product_events_dlq_url" {
  value = module.primary.product_events_dlq_url
}

output "rds_endpoint" {
  value = module.primary.rds_endpoint
}

output "rds_security_group_id" {
  value = module.primary.rds_security_group_id
}

output "alb_dns_name" {
  value = module.primary.alb_dns_name
}