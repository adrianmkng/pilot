remote_state {
  backend = "s3"
  config  = {
    bucket         = "bigw-terraform-state"
    key            = "nonprod/uat/name.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
    dynamodb_table = "bigw-terraform-lock"
  }
}

terraform {
  source = "..//modules/name"
}

inputs = {
  name = "uat"
  org = "bigw"
  private_subnet_cidr = "10.2.0.0/22"
  public_subnet_cidr = "10.2.3.0/24"
  region = "ap-southeast-2"
  root_domain = "bigw-online.net"
  vpc_cidr = "10.2.0.0/16"
  zones = ["a", "b", "c"]
}