variable "region" {}

variable "account_id" {}

variable "environment" {}

variable "domain" {}

variable "zones" {
  type = "list"
}

variable "org" {}

variable "kops_s3_bucket" {}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "public_subnets" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "private_subnets" {
  type = "list"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "kube_version" {}

variable "kube_ami" {}
