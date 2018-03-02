variable "region" {}
variable "name" {}
variable "vpc_id" {}
variable "subnet_cidr" {}
variable "azs" {
  type = "list"
}

resource "aws_subnet" "subnet" {
  count = "${length(var.azs)}"
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${cidrsubnet(var.subnet_cidr, ceil(log(length(var.azs) * 2, 2)), count.index)}"
  availability_zone = "${var.region}${var.azs[count.index]}"

  tags {
    Name = "${var.name}_${var.azs[count.index]}"
    type = "${var.name}"
  }
}

output "subnet_ids" {
  value = "${aws_subnet.subnet.*.id}"
}
