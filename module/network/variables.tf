variable "region" {}

variable "org" {}

variable "account" {}

variable "environment" {}

variable "vpc_cidr" {
  default = "172.20.0.0/16"
}

variable "zones" {
  type    = "list"
  default = ["a", "b", "c"]
}

variable "private_subnets" {
  type = "list"

  default = [
    "172.20.32.0/19",
    "172.20.64.0/19",
    "172.20.96.0/19",
  ]
}

variable "public_subnets" {
  type = "list"

  default = [
    "172.20.0.0/22",
    "172.20.4.0/22",
    "172.20.8.0/22",
  ]
}
