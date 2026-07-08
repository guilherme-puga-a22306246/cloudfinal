variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "AdminMG"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "replicate_source_db" {
  type    = string
  default = null
}