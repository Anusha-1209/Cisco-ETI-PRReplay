locals {
  acceptor_vpc_name  = "liquibase-rds-test"
  requestor_vpc_name = "daboucha-liquibase-2"

}

data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.acceptor_vpc_name]
  }
}

data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.requestor_vpc_name]
  }
}

data "aws_route_tables" "acceptor_vpc_rt" {
  vpc_id = data.aws_vpc.acceptor_vpc.id
}

data "aws_route_tables" "requestor_vpc_rt" {
  vpc_id = data.aws_vpc.requestor_vpc.id
}

data "aws_caller_identity" "current" {}

resource "aws_vpc_peering_connection" "peering_connection" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = data.aws_vpc.acceptor_vpc.id
  vpc_id        = data.aws_vpc.requestor_vpc.id
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "db-to-eks" {
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}

resource "aws_route" "eks-to-db" {
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}
