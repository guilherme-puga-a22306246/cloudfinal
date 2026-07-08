output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

//db replicar

output "db_identifier" {
  value = aws_db_instance.main.identifier
}

output "db_arn" {
  value = aws_db_instance.main.arn
}
