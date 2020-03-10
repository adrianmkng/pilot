variable "root_domain" {
  type = string
}

variable "name" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}
