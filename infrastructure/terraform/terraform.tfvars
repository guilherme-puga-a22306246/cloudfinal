aws_region   = "eu-central-1"
project_name = "cloud-final"
environment  = "dev"

vpc_cidr             = "10.60.0.0/16"
public_subnet_cidrs  = ["10.60.1.0/24", "10.60.2.0/24"]
private_subnet_cidrs = ["10.60.10.0/24", "10.60.20.0/24"]
availability_zones   = ["eu-central-1a", "eu-central-1b"]

instance_type = "t3.small"
key_name      = "week6-key"

allowed_ports = [22, 80, 8080, 8081, 8082, 8083]

db_name     = "appdb"
db_username = "AdminMG"
db_password = "Password123!"
