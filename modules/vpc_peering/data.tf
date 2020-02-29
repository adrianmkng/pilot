data "aws_caller_identity" "accepter" {
  provider = aws.accepter
}

data "aws_vpc" "requester_vpc" {
  provider = aws.requester
  id = var.requester_vpc_id
}

data "aws_vpc" "accepter_vpc" {
  provider = aws.accepter
  id = var.accepter_vpc_id
}

data "aws_route_tables" "requester_route_tables" {
  provider = aws.requester
  vpc_id = var.requester_vpc_id
}

data "aws_route_tables" "accepter_route_tables" {
  provider = aws.accepter
  vpc_id = var.accepter_vpc_id
}
