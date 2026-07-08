locals {
  name_prefix = var.deployment_name == "primary" ? "${var.project_name}-${var.environment}" : "${var.project_name}-${var.environment}-${var.deployment_name}"
}

//para não recriar recursos antigos o primary é o base do cloud-final-dev em vez do cloud-final-dev-primary

module "network" {
  source = "../vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  name_prefix          = local.name_prefix
}

module "compute" {
  source = "../ec2"

  vpc_id        = module.network.vpc_id
  subnet_ids    = module.network.public_subnet_ids
  instance_type = var.instance_type
  key_name      = var.key_name
  allowed_ports = var.allowed_ports
  name_prefix   = local.name_prefix
  subnet_index  = var.subnet_index //index AZ 0 1
}

module "messaging" {
  source = "../sqs"

  name_prefix = local.name_prefix
}

module "database" {
  source = "../rds"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  app_security_group_id = module.compute.security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  replicate_source_db   = var.replicate_source_db //replicar db
}

module "alb" {
  source = "../alb"

  name_prefix       = local.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  instance_id       = module.compute.instance_id
  app_port          = 8080
}