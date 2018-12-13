#data "terraform_remote_state" "account" {
#  backend = "s3"
#
#  config {
#    bucket = "${var.org}-${var.account}-terraform-state"
#    key    = "terraform.tfstate"
#    region = "${var.region}"
#  }
#}

