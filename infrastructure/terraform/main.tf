provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

module "primary" {
  source = "./modules/app_environment"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  instance_type        = var.instance_type
  key_name             = var.key_name
  allowed_ports        = var.allowed_ports
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  deployment_name      = "primary"
  subnet_index         = 0
}


module "standby" {
  source = "./modules/app_environment"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.70.0.0/16"
  public_subnet_cidrs  = ["10.70.1.0/24", "10.70.2.0/24"]
  private_subnet_cidrs = ["10.70.10.0/24", "10.70.20.0/24"]
  availability_zones   = var.availability_zones
  instance_type        = var.instance_type
  key_name             = var.key_name
  allowed_ports        = var.allowed_ports
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  deployment_name      = "standby"
  subnet_index         = 1
}