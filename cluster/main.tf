provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "pilot-terraform"
    key    = "networking/vpc.tfstate"
    region = "ap-southeast-2"
  }
}

# iam roles
resource "aws_iam_instance_profile" "kube_master" {
  name = "kube_master"
  role = "${aws_iam_role.kube_master.name}"
}

resource "aws_iam_instance_profile" "kube_node" {
  name = "kube_node"
  role = "${aws_iam_role.kube_node.name}"
}

resource "aws_iam_role" "kube_master" {
  name               = "kube_master"
  assume_role_policy = "${file("${path.module}/data/kube_master_assume.policy")}"
}

resource "aws_iam_role" "kube_node" {
  name               = "kube_node"
  assume_role_policy = "${file("${path.module}/data/kube_node_assume.policy")}"
}

resource "aws_iam_role_policy" "kube_master" {
  name   = "kube_node"
  role   = "${aws_iam_role.kube_master.name}"
  policy = "${file("${path.module}/data/kube_master_permissions.policy")}"
}

resource "aws_iam_role_policy" "kube_node" {
  name   = "kube_node"
  role   = "${aws_iam_role.kube_node.name}"
  policy = "${file("${path.module}/data/kube_node_permissions.policy")}"
}

# security groups
resource "aws_security_group" "kube_master" {
  name        = "kube_master_sg"
  vpc_id      = "${aws_vpc.main.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "kube-pilot"
    Name              = "kube_master_sg"
  }
}


# launch configs

# auto scaling groups
