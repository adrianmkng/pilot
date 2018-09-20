variable "region" {
  default = "ap-southeast-2"
}

variable "environment" {
  default = "sbx"
}

variable "domain" {
}

variable "zones" {
  type    = "list"
  default = ["a", "b", "c"]
}
