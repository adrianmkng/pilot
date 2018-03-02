provider "aws" {}

variable "region" { default = "ap-southeast-2" }
variable "vpc_cidr" { default = "172.31.0.0/16" }
variable "azs" {
  type = "list"
  default = ["a","b","c"]
}

resource "aws_vpc" "pilot" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "pilot"
  }
}

module "private_subnet" {
  source = "../terraform-subnet"
  region = "${var.region}"
  vpc_id = "${aws_vpc.pilot.id}"
  subnet_cidr = "${cidrsubnet(var.vpc_cidr, 1, 1)}"
  azs = "${var.azs}"
  name = "private"
}

module "public_subnet" {
  source = "../terraform-subnet"
  region = "${var.region}"
  vpc_id = "${aws_vpc.pilot.id}"
  subnet_cidr = "${cidrsubnet(var.vpc_cidr, 1, 0)}"
  azs = "${var.azs}"
  name = "public"
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
  subnet_id = "${element(module.public_subnet.subnet_ids, count.index)}"
}
