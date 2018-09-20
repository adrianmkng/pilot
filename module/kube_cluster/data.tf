data "terraform_remote_state" "account" {
  backend = "s3"

  config {
    bucket = "${var.org}-${var.account}-terraform-state"
    key    = "account.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config {
    bucket = "${var.org}-${var.account}-terraform-state"
    key    = "${var.environment}/network.tfstate"
    region = "${var.region}"
  }
}

data "template_file" "cluster" {
  template = "${file("${path.module}/data/cluster.yaml.tpl")}"

  vars {
    env_domain      = "${var.environment}.${var.domain}"
    kops_s3_bucket  = "${data.terraform_remote_state.account.kops_s3_bucket}"
    region          = "${var.region}"
    vpc_id          = "${data.terraform_remote_state.network.vpc_id}"
    vpc_cidr        = "${data.terraform_remote_state.network.vpc_cidr}"
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
  }
}

data "template_file" "nodes" {
  template = "${file("${path.module}/data/nodes.yaml.tpl")}"

  vars {
    cluster_name = "${local.cluster_name}"
    region       = "${var.region}"
  }
}

data "template_file" "public_subnets" {
  template = "${file("${path.module}/data/subnets.yaml.tpl")}"
  count    = "${length(data.terraform_remote_state.network.public_subnets)}"

  vars {
    id     = "${element(data.terraform_remote_state.network.public_subnet_ids, count.index)}"
    name   = "utility-${var.region}${element(var.zones, count.index)}"
    cidr   = "${element(data.terraform_remote_state.network.public_subnets, count.index)}"
    region = "${var.region}"
    zone   = "${element(var.zones, count.index)}"
    type   = "Utility"
  }
}

data "template_file" "private_subnets" {
  template = "${file("${path.module}/data/subnets.yaml.tpl")}"
  count    = "${length(data.terraform_remote_state.network.private_subnets)}"

  vars {
    id     = "${element(data.terraform_remote_state.network.private_subnet_ids, count.index)}"
    name   = "${var.region}${element(var.zones, count.index)}"
    cidr   = "${element(data.terraform_remote_state.network.private_subnets, count.index)}"
    region = "${var.region}"
    zone   = "${element(var.zones, count.index)}"
    type   = "Private"
  }
}
