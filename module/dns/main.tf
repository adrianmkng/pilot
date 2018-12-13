locals {
  env_domain = "${var.environment}.${var.root_domain}"
}

data "aws_route53_zone" "root" {
  name = "${var.root_domain}."
}

resource "aws_route53_zone" "env_domain" {
  name = "${local.env_domain}"
}

resource "aws_route53_record" "env_ns" {
  zone_id = "${data.aws_route53_zone.root.zone_id}"
  name    = "${local.env_domain}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.env_domain.name_servers.0}",
    "${aws_route53_zone.env_domain.name_servers.1}",
    "${aws_route53_zone.env_domain.name_servers.2}",
    "${aws_route53_zone.env_domain.name_servers.3}",
  ]
}
