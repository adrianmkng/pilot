provider "aws" {}

data "terraform_remote_state" "network" {
  backend = "local"

  config {
    path = "${path.module}/../network/terraform.tfstate"
  }
}

resource "aws_launch_configuration" "kube_master" {
  name          = "kube_master"
  image_id      = "ami-1ca2657e"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "master" {
  name                 = "kube_master"
  launch_configuration = "${aws_launch_configuration.kube_master.name}"
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = ["${data.terraform_remote_state.network.public_subnet_ids}"]

  lifecycle {
    create_before_destroy = true
  }
}
  
resource "aws_launch_configuration" "kube_node" {
  name          = "kube_node"
  image_id      = "ami-1ca2657e"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "node" {
  name                 = "kube_node"
  launch_configuration = "${aws_launch_configuration.kube_node.name}"
  min_size             = 1
  max_size             = 3
  vpc_zone_identifier  = ["${data.terraform_remote_state.network.public_subnet_ids}"]

  lifecycle {
    create_before_destroy = true
  }
}
