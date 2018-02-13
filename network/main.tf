provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "main"
  }
}

resource "aws_subnet" "private" {
  count = "${length(var.azs)}"
  cidr_elems = "${split("//",var.vpc_cidr)}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, cidr_elems[1] + 4, count.index)}"
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags {
    Name = "private_${var.azs[count.index]}"
    type = "private"
  }
}

resource "aws_subnet" "public" {
  count = "${length(var.azs)}"
  cidr_elems = "${split("//",var.vpc_cidr)}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, cidr_elems[1] + 4, 3 + count.index)}"
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags {
    Name = "public_${var.azs[count.index]}"
    type = "public"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "main"
  }
}
