terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.region}"
}

locals {
  cluster_name = "${var.env_domain}"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "aws_ssm_parameter" "private_key" {
  name      = "/${var.environment}/k8s/private_key"
  type      = "SecureString"
  value     = "${tls_private_key.ssh_key.private_key_pem}"
  overwrite = true
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.environment}-k8s"
  public_key = "${tls_private_key.ssh_key.public_key_openssh}"
}

resource "null_resource" "write_public_key" {
  depends_on = ["tls_private_key.ssh_key"]

  provisioner "local-exec" {
    command = "cat > ${path.module}/data/${var.environment}.pub <<EOL\n${tls_private_key.ssh_key.public_key_openssh}"
  }
}

resource "null_resource" "configure_cluster" {
  triggers {
    template = "${data.template_file.cluster.rendered}"
  }

  provisioner "local-exec" {
    command = "cat > ${path.module}/data/cluster.yaml <<EOL\n${data.template_file.cluster.rendered}"
  }

  provisioner "local-exec" {
    command = "kops replace -f ${path.module}/data/cluster.yaml --force --state s3://${data.terraform_remote_state.account.kops_s3_bucket}"
  }
}

resource "null_resource" "configure_masters" {
  depends_on = ["null_resource.configure_cluster"]

  triggers {
    template = "${data.template_file.master.rendered}"
  }

  provisioner "local-exec" {
    command = "cat > ${path.module}/data/master_${var.region}a.yaml <<EOL\n${data.template_file.master.rendered}"
  }

  provisioner "local-exec" {
    command = "kops replace -f ${path.module}/data/master_${var.region}a.yaml --force --state s3://${data.terraform_remote_state.account.kops_s3_bucket}"
  }
}

resource "null_resource" "configure_nodes" {
  depends_on = ["null_resource.configure_cluster"]

  triggers {
    template = "${data.template_file.nodes.rendered}"
  }

  provisioner "local-exec" {
    command = "cat > ${path.module}/data/nodes.yaml <<EOL\n${data.template_file.nodes.rendered}"
  }

  provisioner "local-exec" {
    command = "kops replace -f ${path.module}/data/nodes.yaml --force --state s3://${data.terraform_remote_state.account.kops_s3_bucket}"
  }
}

resource "null_resource" "create_secret_key" {
  depends_on = ["null_resource.configure_cluster", "null_resource.write_public_key"]

  provisioner "local-exec" {
    command = "kops create secret --name ${var.env_domain} sshpublickey admin -i ${path.module}/data/${var.environment}.pub --state s3://${data.terraform_remote_state.account.kops_s3_bucket}"
  }
}

//resource "null_resource" "create_cluster" {
//  depends_on = ["null_resource.configure_cluster", "null_resource.write_public_key", "null_resource.create_secret_key"]
//
//  provisioner "local-exec" {
//    command = "kops update cluster --name ${var.env_domain} --yes --state s3://${data.terraform_remote_state.account.kops_s3_bucket}"
//  }
//}

resource "null_resource" "delete_cluster" {
  provisioner "local-exec" {
    command = "kops delete cluster --name=${local.cluster_name} --yes --state s3://${data.terraform_remote_state.account.kops_s3_bucket}"
    when    = "destroy"
  }
}
