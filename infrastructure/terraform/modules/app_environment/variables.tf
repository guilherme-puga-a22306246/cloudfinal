variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "allowed_ports" {
  type = list(number)
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "deployment_name" {
  type = string
}

variable "subnet_index" {
  type    = number
  default = 0
}

variable "replicate_source_db" {
  type    = string
  default = null
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

//corrigir erro de destroy do rds para mudar standby de region
variable "skip_final_snapshot" {
  type    = bool
  default = false
}

//cross region KMS encryption key for standby RDS replica
variable "kms_key_id" {
  type    = string
  default = null
}