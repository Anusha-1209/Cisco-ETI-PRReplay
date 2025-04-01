terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-dragonfly-staging/vpc-peering/eu-west-1/dragonfly-staging-compute-1-to-data-1-vpc-peering-1/vpc-peering.tfstate"
    region = "us-east-2"
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-staging/terraform_admins"
  provider = vault.eticloud
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["dragonfly-compute-staging-1-vpc"]
  }
}

data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["dragonfly-data-staging-1-vpc"]
  }
}

data "aws_route_tables" "requestor_vpc_rt" {
  vpc_id = data.aws_vpc.requestor_vpc.id
}

data "aws_route_tables" "acceptor_vpc_rt" {
  vpc_id = data.aws_vpc.acceptor_vpc.id
}

# Use this to get the account ID
data "aws_caller_identity" "current" {}


# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-west-1"
  max_retries = 3
}

# VPC peering resources
resource "aws_vpc_peering_connection" "data_to_compute" {
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

  tags = {
    Name               = "VPC Peering between dragonfly-staging-compute-vpc-1 and dragonfly-staging-data-vpc-1"
    ApplicationName    = "nonprod-dragonfly-staging-compute-data-peering"
    CiscoMailAlias     = "eti-sre@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}

# VPC routing resources
resource "aws_route" "compute_to_data" {
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.data_to_compute.id
}

resource "aws_route" "data_to_compute" {
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.data_to_compute.id
}

# Security groups
resource "aws_security_group" "compute_to_data" {
  name        = "compute-vpc-1-to-data-vpc-1"
  description = "Allows all communication into data-vpc-1 from the compute-vpc-1"
  vpc_id      = data.aws_vpc.acceptor_vpc.id
}

resource "aws_security_group" "data_to_compute" {
  name        = "data-vpc-1-to-compute-vpc-1"
  description = "Allows all communication into compute-vpc-1 from the data-vpc-1"
  vpc_id      = data.aws_vpc.requestor_vpc.id
}

# security group rules because the rules are going to reference the groups
resource "aws_security_group_rule" "compute_to_data" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.compute_to_data.id
  source_security_group_id = aws_security_group.data_to_compute.id
}

resource "aws_security_group_rule" "data_to_compute" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.data_to_compute.id
  source_security_group_id = aws_security_group.compute_to_data.id
}
