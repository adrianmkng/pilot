variable "region" {
  default = "ap-southeast-2"
}

variable "azs" {
  type = "list"
  default = ["a","b","c"]
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}
