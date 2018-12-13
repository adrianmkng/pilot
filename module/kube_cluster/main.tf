terraform {
  backend "s3" {}
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
    command = <<EOF
SESSION=`aws sts assume-role --role-arn arn:aws:iam::${var.account_id}:role/${var.org}/kops --role-session-name terragrunt`
export AWS_ACCESS_KEY_ID=`echo "$$SESSION" | jq -r .Credentials.AccessKeyId`
export AWS_SECRET_ACCESS_KEY=`echo "$$SESSION" | jq -r .Credentials.SecretAccessKey`
export AWS_SESSION_TOKEN=`echo "$$SESSION" | jq -r .Credentials.SessionToken`
kops replace -f ${path.module}/data/cluster.yaml --force --state s3://${var.kops_s3_bucket}
EOF
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
    command = <<EOF
SESSION=`aws sts assume-role --role-arn arn:aws:iam::${var.account_id}:role/${var.org}/kops --role-session-name terragrunt`
export AWS_ACCESS_KEY_ID=`echo "$$SESSION" | jq -r .Credentials.AccessKeyId`
export AWS_SECRET_ACCESS_KEY=`echo "$$SESSION" | jq -r .Credentials.SecretAccessKey`
export AWS_SESSION_TOKEN=`echo "$$SESSION" | jq -r .Credentials.SessionToken`
kops replace -f ${path.module}/data/master_${var.region}a.yaml --force --state s3://${var.kops_s3_bucket}
EOF
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
    command = <<EOF
SESSION=`aws sts assume-role --role-arn arn:aws:iam::${var.account_id}:role/${var.org}/kops --role-session-name terragrunt`
export AWS_ACCESS_KEY_ID=`echo "$$SESSION" | jq -r .Credentials.AccessKeyId`
export AWS_SECRET_ACCESS_KEY=`echo "$$SESSION" | jq -r .Credentials.SecretAccessKey`
export AWS_SESSION_TOKEN=`echo "$$SESSION" | jq -r .Credentials.SessionToken`
kops replace -f ${path.module}/data/nodes.yaml --force --state s3://${var.kops_s3_bucket}
EOF
  }
}

resource "null_resource" "create_secret_key" {
  depends_on = ["null_resource.configure_cluster", "null_resource.write_public_key"]

  provisioner "local-exec" {
    command = <<EOF
SESSION=`aws sts assume-role --role-arn arn:aws:iam::${var.account_id}:role/${var.org}/kops --role-session-name terragrunt`
export AWS_ACCESS_KEY_ID=`echo "$$SESSION" | jq -r .Credentials.AccessKeyId`
export AWS_SECRET_ACCESS_KEY=`echo "$$SESSION" | jq -r .Credentials.SecretAccessKey`
export AWS_SESSION_TOKEN=`echo "$$SESSION" | jq -r .Credentials.SessionToken`
kops create secret --name ${local.cluster_name} sshpublickey admin -i ${path.module}/data/${var.environment}.pub --state s3://${var.kops_s3_bucket}
EOF
  }
}

resource "null_resource" "create_cluster" {
  depends_on = ["null_resource.configure_cluster", "null_resource.write_public_key", "null_resource.create_secret_key"]

  provisioner "local-exec" {
    command = <<EOF
SESSION=`aws sts assume-role --role-arn arn:aws:iam::${var.account_id}:role/${var.org}/kops --role-session-name terragrunt`
export AWS_ACCESS_KEY_ID=`echo "$$SESSION" | jq -r .Credentials.AccessKeyId`
export AWS_SECRET_ACCESS_KEY=`echo "$$SESSION" | jq -r .Credentials.SecretAccessKey`
export AWS_SESSION_TOKEN=`echo "$$SESSION" | jq -r .Credentials.SessionToken`
kops update cluster --name ${local.cluster_name} --yes --state s3://${var.kops_s3_bucket}
EOF
  }
}

resource "null_resource" "delete_cluster" {
  provisioner "local-exec" {
    command = <<EOF
SESSION=`aws sts assume-role --role-arn arn:aws:iam::${var.account_id}:role/${var.org}/kops --role-session-name terragrunt`
export AWS_ACCESS_KEY_ID=`echo "$$SESSION" | jq -r .Credentials.AccessKeyId`
export AWS_SECRET_ACCESS_KEY=`echo "$$SESSION" | jq -r .Credentials.SecretAccessKey`
export AWS_SESSION_TOKEN=`echo "$$SESSION" | jq -r .Credentials.SessionToken`
kops delete cluster --name=${local.cluster_name} --yes --state s3://${var.kops_s3_bucket}
EOF

    when = "destroy"
  }
}
