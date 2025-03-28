provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/eticloud/terraform_admin"
  provider = vault.eticloud
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/vpc-peering/us-east-2/old-data-eks-common-prod-1.tfstate"
    region = "us-east-2"
  }
}

locals {
  new_acceptor_vpc_name  = "eks-common-prod-1"
  old_requestor_vpc_name = "prod-db-vpc-1"
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "new_acceptor_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.new_acceptor_vpc_name]
  }
}

data "aws_vpc" "old_requestor_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.old_requestor_vpc_name]
  }
}

data "aws_route_tables" "new_acceptor_vpc_rt" {
  vpc_id = data.aws_vpc.new_acceptor_vpc.id
}

data "aws_route_tables" "old_requestor_vpc_rt" {
  vpc_id = data.aws_vpc.old_requestor_vpc.id
}

# Use this to get the account ID
data "aws_caller_identity" "current" {}


# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      Name               = "VPC Peering between ${local.new_acceptor_vpc_name} and ${local.old_requestor_vpc_name}"
      ApplicationName    = "${local.new_acceptor_vpc_name}-vpc-peering"
      CiscoMailAlias     = "eti-sre@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

# VPC peering resources
resource "aws_vpc_peering_connection" "old_peering_connection" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = data.aws_vpc.new_acceptor_vpc.id
  vpc_id        = data.aws_vpc.old_requestor_vpc.id
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

# VPC routing resources
resource "aws_route" "old-db-to-eks" {
  count                     = length(data.aws_route_tables.old_requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.old_requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.new_acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.old_peering_connection.id
}

resource "aws_route" "eks-to-old-db" {
  count                     = length(data.aws_route_tables.new_acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.new_acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.old_requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.old_peering_connection.id
}
