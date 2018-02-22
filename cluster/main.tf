provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_vpc" "main" {
  tags = {
    "Name"= "main"
  }
}

data "aws_subnet_ids" "main" {
  vpc_id = "${data.aws_vpc.main.id}"
  tags = {
    "type"= "public"
  }
}
  

resource "aws_launch_configuration" "k8s" {
  name          = "kube_node"
  image_id      = "ami-1ca2657e"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "master" {
  name                 = "kube_master"
  launch_configuration = "${aws_launch_configuration.k8s.name}"
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = ["${data.aws_subnet_ids.main.ids}"]

  lifecycle {
    create_before_destroy = true
  }
}
