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
}