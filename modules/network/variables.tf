variable "name" {
  description = "Name to be used on all the resources as identifier"
  type = string
}

variable "zones" {
  description = "A list of availability zones letters."
  type = list(string)
  default     = ["a", "b", "c"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type = string
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "private_subnet_cidr" {
  description = "The CIDR block for private subnets inside the VPC, evenly divided up across availabilty zones."
  type = string
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_cidr" {
  description = "The CIDR block for public subnets inside the VPC, evenly divided up across availabilty zones."
  type = string
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

