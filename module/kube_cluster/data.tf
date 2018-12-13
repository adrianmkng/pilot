locals {
  cluster_name = "k8s.${var.domain}"
}

data "template_file" "cluster" {
  template = "${file("${path.module}/data/cluster.yaml.tpl")}"

  vars {
    cluster_name    = "${local.cluster_name}"
    version         = "${var.kube_version}"
    kops_s3_bucket  = "${var.kops_s3_bucket}"
    region          = "${var.region}"
    vpc_id          = "${var.vpc_id}"
    vpc_cidr        = "${var.vpc_cidr}"
    public_subnets  = "${join("\n", data.template_file.public_subnets.*.rendered)}"
    private_subnets = "${join("\n", data.template_file.private_subnets.*.rendered)}"
  }
}

data "template_file" "master" {
  template = "${file("${path.module}/data/master.yaml.tpl")}"

  vars {
    cluster_name = "${local.cluster_name}"
    region       = "${var.region}"
    az           = "a"
    ami          = "${var.kube_ami}"
  }
}

data "template_file" "nodes" {
  template = "${file("${path.module}/data/nodes.yaml.tpl")}"

  vars {
    cluster_name = "${local.cluster_name}"
    region       = "${var.region}"
    ami          = "${var.kube_ami}"
  }
}

data "template_file" "public_subnets" {
  template = "${file("${path.module}/data/subnets.yaml.tpl")}"
  count    = "${length(var.zones)}"

  vars {
    id     = "${element(var.public_subnet_ids, count.index)}"
    name   = "utility-${var.region}${element(var.zones, count.index)}"
    cidr   = "${element(var.public_subnets, count.index)}"
    region = "${var.region}"
    zone   = "${element(var.zones, count.index)}"
    type   = "Utility"
  }
}

data "template_file" "private_subnets" {
  template = "${file("${path.module}/data/subnets.yaml.tpl")}"
  count    = "${length(var.zones)}"

  vars {
    id     = "${element(var.private_subnet_ids, count.index)}"
    name   = "${var.region}${element(var.zones, count.index)}"
    cidr   = "${element(var.private_subnets, count.index)}"
    region = "${var.region}"
    zone   = "${element(var.zones, count.index)}"
    type   = "Private"
  }
}
