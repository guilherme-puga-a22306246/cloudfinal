output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "instance_id" {
  value = module.compute.instance_id
}

output "instance_public_ip" {
  value = module.compute.public_ip
}

output "app_security_group_id" {
  value = module.compute.security_group_id
}

output "product_events_queue_url" {
  value = module.messaging.queue_url
}

output "product_events_queue_arn" {
  value = module.messaging.queue_arn
}

output "product_events_dlq_url" {
  value = module.messaging.dlq_url
}

output "rds_endpoint" {
  value = module.database.db_endpoint
}

output "rds_security_group_id" {
  value = module.database.rds_security_group_id
}

output "alb_dns_name" {
  value = module.alb.dns_name
}

//db replicar

output "db_identifier" {
  value = module.database.db_identifier
}

output "db_arn" {
  value = module.database.db_arn
}