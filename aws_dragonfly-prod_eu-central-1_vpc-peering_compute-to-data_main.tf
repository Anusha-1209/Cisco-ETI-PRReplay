terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/dragonfly-prod/eu-central-1/vpc-peering/compute-to-data/vpc-peering.tfstate"
    region = "us-east-2"
  }
}

provider "vault" {
  alias     = "eticloud_eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/dragonfly-production/aws"
  provider = vault.eticloud_eticcprod
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["dragonfly-prod-euc1-1"]
  }
}

# VPC created from sre-tf-infra, not migrated to this repo
# https://wwwin-github.cisco.com/eti/sre-tf-infra/tree/main/aws-dragonfly-production/vpc/eu-central-1/dragonfly-prod-data-euc1-1
data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["dragonfly-prod-data-euc1-1"]
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
  region      = "eu-central-1"
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
    Name                  = "VPC Peering between dragonfly-prod-euc1-1 and dragonfly-prod-data-euc1-1"
    CSBApplicationName    = "prod-dragonfly-compute-data-peering"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy       = "Cisco Operations Data"
    CSBEnvironment        = "Prod"
    CSBResourceOwner      = "Outshift SRE"
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
  name        = "compute-vpc-to-data-pvc"
  description = "Allows all communication into data-pvc from the compute-pvc"
  vpc_id      = data.aws_vpc.acceptor_vpc.id
}

resource "aws_security_group" "data_to_compute" {
  name        = "data-vpc-to-compute-pvc"
  description = "Allows all communication into compute-pvc from the data-pvc"
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
