output "vpc_id" {
  value = "${aws_vpc.env.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.env.cidr_block}"
}

output "domain_name" {
  value = "${local.env_domain}"
}

output "public_subnets" {
  value = "${var.public_subnets}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public.*.id}"
}

output "private_subnets" {
  value = "${var.private_subnets}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.private.*.id}"
}

output "public_route_table_id" {
  value = "${aws_route_table.public.id}"
}

output "private_route_table_ids" {
  value = "${aws_route_table.private.*.id}"
}
