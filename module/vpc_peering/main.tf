terraform {
  backend "s3" {}
}

resource "aws_vpc_peering_connection" "peer" {
  provider      = aws.requester
  peer_owner_id = data.aws_caller_identity.accepter.account_id
  peer_vpc_id   = var.accepter_vpc_id
  vpc_id        = var.requester_vpc_id
  auto_accept   = false

  tags = {
    Name = "${data.aws_vpc.requester_vpc.tags["Name"]}-${data.aws_vpc.accepter_vpc.tags["Name"]}"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Name = "${data.aws_vpc.requester_vpc.tags["Name"]}-${data.aws_vpc.accepter_vpc.tags["Name"]}"
  }
}

resource "aws_vpc_peering_connection_options" "accepter_opts" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "requester_opts" {
  provider                  = aws.requester
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "requester_routes" {
  provider                  = aws.requester
  for_each                  = data.aws_route_tables.requester_route_tables.ids
  route_table_id            = each.value
  destination_cidr_block    = data.aws_vpc.accepter_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

resource "aws_route" "accepter_routes" {
  provider                  = aws.accepter
  for_each                  = data.aws_route_tables.accepter_route_tables.ids
  route_table_id            = each.value
  destination_cidr_block    = data.aws_vpc.requester_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}
