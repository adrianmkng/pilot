variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "ap-southeast-2"
}

variable "azs" {
    type = "list"
    default = ["a","b","c"]
}

