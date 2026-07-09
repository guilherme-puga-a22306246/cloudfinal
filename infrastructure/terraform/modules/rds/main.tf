resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow PostgreSQL access from application security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-rds-sg"
  }
}

resource "aws_db_instance" "main" {

  identifier          = "${var.name_prefix}-database"
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp3"
  replicate_source_db = var.replicate_source_db

  db_name  = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_username : null
  password = var.replicate_source_db == null ? var.db_password : null

  backup_retention_period   = var.backup_retention_period
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  publicly_accessible       = false
  multi_az                  = true
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-final-snapshot"
  storage_encrypted         = true
  deletion_protection       = false
  kms_key_id                = var.kms_key_id

  tags = {
    Name = "${var.name_prefix}-database"
  }
  lifecycle {
    ignore_changes = [
      replicate_source_db
    ]
  }
}
