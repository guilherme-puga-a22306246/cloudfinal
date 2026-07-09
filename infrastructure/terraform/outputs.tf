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

output "app_security_group_id" {
  value = module.primary.app_security_group_id
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

output "primary_instance_public_ip" {
  value = module.primary.instance_public_ip
}

output "primary_alb_dns_name" {
  value = module.primary.alb_dns_name
}

output "primary_product_events_queue_url" {
  value = module.primary.product_events_queue_url
}

output "standby_instance_public_ip" {
  value = module.standby.instance_public_ip
}

output "standby_alb_dns_name" {
  value = module.standby.alb_dns_name
}

output "standby_product_events_queue_url" {
  value = module.standby.product_events_queue_url
}

output "primary_instance_id" {
  value = module.primary.instance_id
}

output "standby_instance_id" {
  value = module.standby.instance_id
}

//route 53

output "primary_alb_zone_id" {
  value = module.primary.alb_zone_id
}

output "standby_alb_zone_id" {
  value = module.standby.alb_zone_id
}