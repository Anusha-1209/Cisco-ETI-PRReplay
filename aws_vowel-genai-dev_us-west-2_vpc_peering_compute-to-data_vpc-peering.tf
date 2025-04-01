provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/vowel-genai-dev/terraform_admin"
  provider = vault.eticloud
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-east-2/data-motific-dev-usw2-1.tfstate"
    region = "us-east-2"
  }
}

locals {
  acceptor_vpc_name  = "vowel-dev-1-vpc"       # EKS cluster in us-east-2
  requestor_vpc_name = "motific-dev-usw2-data" # RDS cluster in us-west-2
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "acceptor_vpc" {
  provider = aws.primary
  filter {
    name   = "tag:Name"
    values = [local.acceptor_vpc_name]
  }
}

data "aws_vpc" "requestor_vpc" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = [local.requestor_vpc_name]
  }
}

data "aws_route_tables" "acceptor_vpc_rt" {
  provider = aws.primary
  vpc_id   = data.aws_vpc.acceptor_vpc.id
}

data "aws_route_tables" "requestor_vpc_rt" {
  provider = aws.secondary
  vpc_id   = data.aws_vpc.requestor_vpc.id
}

# Use this to get the account ID
data "aws_caller_identity" "current" {
  provider = aws.primary
}


# VPC peering resources
resource "aws_vpc_peering_connection" "peering_connection" {
  provider      = aws.primary
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



# VPC routing resources
resource "aws_route" "db-to-eks" {
  provider                  = aws.secondary
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}

resource "aws_route" "eks-to-db" {
  provider                  = aws.primary
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}
