terraform {
  backend "s3" {}
}

module "network" {
  source = "../network"

  org = var.org
  environment = var.environment
  region = var.region
  zones = var.zones
  vpc_cidr = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "dns" {
  source = "../dns"

  environment = var.environment
  root_domain = var.root_domain
}