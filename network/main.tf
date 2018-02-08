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
  count = "${length(azs)}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 24, count.index)}"
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags {
    Name = "private_${var.azs[count.index]}"
    type = "private"
  }
}

resource "aws_subnet" "public" {
  count = "${length(var.azs)}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr, 24, 3 + count.index)}"
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags {
    Name = "public_${var.azs[count.index]}"
    type = "public"
  }
}
