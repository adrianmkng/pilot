variable "region" {}

variable "org" {}

variable "account" {}

variable "account_id" {}

variable "environment" {}

variable "zones" {
  type = "list"
}

variable "vpc_cidr" {}

variable "private_subnet_cidr" {}

variable "public_subnet_cidr" {}
