locals {
  subdomain = "${var.name}.${var.root_domain}"
}

data "aws_route53_zone" "root" {
  name = "${var.root_domain}."
}

resource "aws_route53_zone" "env_domain" {
  name = local.subdomain
}

resource "aws_route53_record" "env_ns" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.subdomain
  type    = "NS"
  ttl     = "30"

  records = aws_route53_zone.env_domain.name_servers
}
