terraform {
  backend "s3" {}
}

module "network" {
  source = "../network"

  name = var.name
  zones = var.zones
  vpc_cidr = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "dns" {
  source = "../dns"

  name = var.name
  root_domain = var.root_domain
}