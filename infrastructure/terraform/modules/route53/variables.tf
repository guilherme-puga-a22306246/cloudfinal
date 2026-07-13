variable "hosted_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "primary_alb_dns_name" {
  type = string
}

variable "primary_alb_zone_id" {
  type = string
}

variable "standby_alb_dns_name" {
  type = string
}

variable "standby_alb_zone_id" {
  type = string
}

variable "active_region" {
  type = string

  validation {
    condition = contains(
      ["eu-central-1", "eu-west-1"],
      var.active_region
    )

    error_message = "active_region must be eu-central-1 or eu-west-1."
  }
}
