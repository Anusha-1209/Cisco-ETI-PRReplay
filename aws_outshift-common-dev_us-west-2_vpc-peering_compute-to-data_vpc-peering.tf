provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  alias = "acceptor"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-west-2"
  max_retries = 3
  default_tags {
    tags = {
      Name               = "VPC Peering between ${local.acceptor_vpc_name} and ${local.requestor_vpc_name}"
      ApplicationName    = "${local.acceptor_vpc_name}-vpc-peering"
      CiscoMailAlias     = "eti-sre@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

provider "aws" {
  alias = "requester"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      Name               = "VPC Peering between ${local.acceptor_vpc_name} and ${local.requestor_vpc_name}"
      ApplicationName    = "${local.acceptor_vpc_name}-vpc-peering"
      CiscoMailAlias     = "eti-sre@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/outshift-common-dev/terraform_admin"
  provider = vault.eticloud
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/vpc-peering/us-west-2/data-comn-dev-usw2-1.tfstate"
    region = "us-east-2"
  }
}

locals {
  acceptor_vpc_name  = "comn-dev-usw2-1"
  requestor_vpc_name = "common-dev-vpc-data"
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "acceptor_vpc" {
  provider = aws.acceptor
  filter {
    name   = "tag:Name"
    values = [local.acceptor_vpc_name]
  }
}

data "aws_vpc" "requestor_vpc" {
  provider = aws.requester
  filter {
    name   = "tag:Name"
    values = [local.requestor_vpc_name]
  }
}

data "aws_route_tables" "acceptor_vpc_rt" {
  provider = aws.acceptor
  vpc_id   = data.aws_vpc.acceptor_vpc.id
}

data "aws_route_tables" "requestor_vpc_rt" {
  provider = aws.requester
  vpc_id   = data.aws_vpc.requestor_vpc.id
}

# Use this to get the account ID
data "aws_caller_identity" "current" {
  provider = aws.requester
}

data "aws_region" "requester" {
  provider = aws.requester
}
data "aws_region" "acceptor" {
  provider = aws.acceptor
}

# VPC peering resources
resource "aws_vpc_peering_connection" "peering_connection" {
  provider      = aws.requester
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = data.aws_vpc.acceptor_vpc.id
  vpc_id        = data.aws_vpc.requestor_vpc.id
  peer_region   = data.aws_region.acceptor.name
}

######################################
# VPC peering accepter configuration #
######################################
resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider                  = aws.acceptor
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
  auto_accept               = true
}

#######################
# VPC peering options #
#######################
resource "aws_vpc_peering_connection_options" "requester" {
  provider                  = aws.requester
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer_accepter.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider                  = aws.acceptor
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer_accepter.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

###################
# This VPC Routes #  Routes from THIS route table to PEER CIDR
###################
resource "aws_route" "requester_routes" {
  provider                  = aws.requester
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}

###################
# Peer VPC Routes #  Routes from PEER route table to THIS CIDR
###################
resource "aws_route" "acceptor_routes" {
  provider                  = aws.acceptor
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}
