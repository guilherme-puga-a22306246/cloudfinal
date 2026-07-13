provider "aws" {
  alias  = "primary"
  region = "eu-central-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

provider "aws" {
  alias  = "standby"
  region = "eu-west-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_ssm_parameter" "active_region" {
  provider = aws.primary
  name     = "/cloud-final/dr/active-region"
}

data "aws_caller_identity" "current" {}

locals {
  active_region = data.aws_ssm_parameter.active_region.value

  central_db_arn = "arn:aws:rds:eu-central-1:${data.aws_caller_identity.current.account_id}:db:cloud-final-dev-database"
  west_db_arn    = "arn:aws:rds:eu-west-1:${data.aws_caller_identity.current.account_id}:db:cloud-final-dev-standby-database"
}

resource "aws_kms_key" "primary_rds" {
  provider = aws.primary

  description             = "KMS key for eu-central-1 RDS replica"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "primary_rds" {
  provider = aws.primary

  name          = "alias/cloud-final-primary-rds"
  target_key_id = aws_kms_key.primary_rds.key_id
}

resource "aws_kms_key" "standby_rds" {
  provider = aws.standby

  description             = "KMS key for standby RDS replica"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "standby_rds" {
  provider = aws.standby

  name          = "alias/cloud-final-standby-rds"
  target_key_id = aws_kms_key.standby_rds.key_id
}

module "primary" {
  source = "./modules/app_environment"

  providers = {
    aws = aws.primary
  }

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
  replicate_source_db  = local.active_region == "eu-west-1" ? local.west_db_arn : null
  kms_key_id           = local.active_region == "eu-west-1" ? aws_kms_key.primary_rds.arn : null
}


module "standby" {
  source = "./modules/app_environment"

  providers = {
    aws = aws.standby
  }

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.70.0.0/16"
  public_subnet_cidrs  = ["10.70.1.0/24", "10.70.2.0/24"]
  private_subnet_cidrs = ["10.70.10.0/24", "10.70.20.0/24"]
  availability_zones   = ["eu-west-1a", "eu-west-1b"]
  instance_type        = var.instance_type
  key_name             = var.key_name
  allowed_ports        = var.allowed_ports
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  deployment_name      = "standby"
  subnet_index         = 1
  replicate_source_db  = local.active_region == "eu-central-1" ? local.central_db_arn : null
  kms_key_id           = local.active_region == "eu-central-1" ? aws_kms_key.standby_rds.arn : null
  skip_final_snapshot  = true
}

module "route53" {
  source = "./modules/route53"

  providers = {
    aws = aws.primary
  }

  hosted_zone_id = "Z0992149358N66C01DB6Y"
  domain_name    = "cloud.guilhermepuga.pt"
  active_region  = local.active_region

  primary_alb_dns_name = module.primary.alb_dns_name
  primary_alb_zone_id  = module.primary.alb_zone_id
  standby_alb_dns_name = module.standby.alb_dns_name
  standby_alb_zone_id  = module.standby.alb_zone_id
}