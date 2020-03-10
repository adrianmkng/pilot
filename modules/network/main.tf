terraform {
  backend "s3" {}
}

data "aws_region" current {}

resource "aws_vpc" "env" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
  {
    Name = var.name
  },
  var.vpc_tags,
  )
}

resource "aws_subnet" "private" {
  count             = length(var.zones)
  vpc_id            = aws_vpc.env.id
  cidr_block        = cidrsubnet(var.private_subnet_cidr, ceil(log(length(var.zones), 2)), count.index)
  availability_zone = "${data.aws_region.current.name}${element(var.zones, count.index)}"

  tags = merge(
  {
    Name       = "${var.name}.private-${data.aws_region.current.name}${element(var.zones, count.index)}"
  },
  var.private_subnet_tags,
  )
}

resource "aws_subnet" "public" {
  count             = length(var.zones)
  vpc_id            = aws_vpc.env.id
  cidr_block        = cidrsubnet(var.public_subnet_cidr, ceil(log(length(var.zones), 2)), count.index)
  availability_zone = "${data.aws_region.current.name}${element(var.zones, count.index)}"

  tags = merge(
  {
    Name       = "${var.name}.public-${data.aws_region.current.name}${element(var.zones, count.index)}"
  },
  var.public_subnet_tags,
  )
}

resource "aws_eip" "nat" {
  for_each = var.zones
  vpc   = true

  tags = {
    Name = "${var.name}.${data.aws_region.current.name}${each.value}"
  }
}

resource "aws_internet_gateway" "env" {
  vpc_id = aws_vpc.env.id

  tags = {
    Name = var.name
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.zones)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = {
    Name = "${var.name}.${data.aws_region.current.name}${element(var.zones, count.index)}"
  }
}

resource "aws_route_table" "private" {
  for_each = var.zones
  vpc_id = aws_vpc.env.id

  tags = {
    Name = "${var.name}.private-${data.aws_region.current.name}${each.value}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.env.id

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.zones)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = length(var.zones)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.env.id
}

resource "aws_route" "private_default" {
  count                  = length(var.zones)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}
