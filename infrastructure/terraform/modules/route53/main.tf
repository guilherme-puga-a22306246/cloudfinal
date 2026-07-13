moved {
  from = aws_route53_health_check.primary
  to   = aws_route53_health_check.central
}

moved {
  from = aws_route53_health_check.standby
  to   = aws_route53_health_check.west
}

moved {
  from = aws_route53_record.primary
  to   = aws_route53_record.active
}

moved {
  from = aws_route53_record.standby
  to   = aws_route53_record.passive
}

locals {
  central_is_active = var.active_region == "eu-central-1"

  active_alb_dns_name = (
    local.central_is_active
    ? var.primary_alb_dns_name
    : var.standby_alb_dns_name
  )

  active_alb_zone_id = (
    local.central_is_active
    ? var.primary_alb_zone_id
    : var.standby_alb_zone_id
  )

  passive_alb_dns_name = (
    local.central_is_active
    ? var.standby_alb_dns_name
    : var.primary_alb_dns_name
  )

  passive_alb_zone_id = (
    local.central_is_active
    ? var.standby_alb_zone_id
    : var.primary_alb_zone_id
  )
}


resource "aws_route53_health_check" "central" {
  fqdn              = var.primary_alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/actuator/health"
  request_interval  = 30
  failure_threshold = 3

  tags = {
    Name = "eu-central-1-alb-health-check"
  }
}

resource "aws_route53_health_check" "west" {
  fqdn              = var.standby_alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/actuator/health"
  request_interval  = 30
  failure_threshold = 3

  tags = {
    Name = "eu-west-1-alb-health-check"
  }
}

resource "aws_route53_record" "active" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "primary"

  failover_routing_policy {
    type = "PRIMARY"
  }

  health_check_id = (
    local.central_is_active
    ? aws_route53_health_check.central.id
    : aws_route53_health_check.west.id
  )

  alias {
    name                   = local.active_alb_dns_name
    zone_id                = local.active_alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "passive" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "standby"

  failover_routing_policy {
    type = "SECONDARY"
  }

  health_check_id = (
    local.central_is_active
    ? aws_route53_health_check.west.id
    : aws_route53_health_check.central.id
  )

  alias {
    name                   = local.passive_alb_dns_name
    zone_id                = local.passive_alb_zone_id
    evaluate_target_health = true
  }
}