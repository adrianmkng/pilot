provider "aws" {}

resource "aws_vpc" "pilot" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "pilot"
  }
}

resource "aws_subnet" "private" {
  count = "${length(var.azs)}"
  vpc_id     = "${aws_vpc.pilot.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 4, count.index)}"
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags {
    Name = "private_${var.azs[count.index]}"
    type = "private"
  }
}

resource "aws_subnet" "public" {
  count = "${length(var.azs)}"
  vpc_id     = "${aws_vpc.pilot.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 4, 3 + count.index)}"
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags {
    Name = "public_${var.azs[count.index]}"
    type = "public"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.pilot.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.pilot.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "pilot"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(var.azs)}"

  route_table_id = "${aws_route_table.public.id}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}
