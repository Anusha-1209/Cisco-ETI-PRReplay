# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".

provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}


data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/prod/aws"
  provider = vault.eticcprod
}
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"                                                                               # Do not change without talking to the SRE team.
    key    = "terraform-state/vpc-peering/us-east-2/nonprod-db-eks-kosha-staging/nonprod-db-eks-kosha-staging.tfstate" # The statefile name should be descriptive and must be unique.
    region = "us-east-2"                                                                                               # Do not change without talking to the SRE team.
  }
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:Name"
    values = ["eks-kosha-staging-vpc"]
  }
}

data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:Name"
    values = ["nonprod-db-vpc-1"]
  }
}

data "aws_route_tables" "acceptor_vpc_rt" {
  vpc_id = data.aws_vpc.acceptor_vpc.id
}

data "aws_route_tables" "requestor_vpc_rt" {
  vpc_id = data.aws_vpc.requestor_vpc.id
}

# Use this to get the account ID
data "aws_caller_identity" "current" {}


# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}

# VPC peering resources
resource "aws_vpc_peering_connection" "nonprod-db-eks-kosha-staging" {
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
    Name                  = "VPC Peering between eks-kosha-staging and nonprod-db-vpc-1"
    CSBApplicationName    = "nonprod-db-eks-kosha-staging-peering"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy       = "Cisco Operations Data"
    CSBEnvironment        = "NonProd"
    CSBResourceOwner      = "ETI SRE"
  }
}

# VPC routing resources
resource "aws_route" "db-to-dev" {
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.nonprod-db-eks-kosha-staging.id
}

resource "aws_route" "dev-to-db" {
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.nonprod-db-eks-kosha-staging.id
}

# security groups

resource "aws_security_group" "nonprod-db-vpc-1-to-eks-kosha-staging" {
  name = "nonprod-db-vpc-1-to-eks-kosha-staging"
  description = "Allows all communication into eks-kosha-staging from the non-production db vpc"
  vpc_id = data.aws_vpc.acceptor_vpc.id
}

resource "aws_security_group" "eks-kosha-staging-to-nonprod-db-vpc-1" {
  name = "eks-kosha-staging-to-nonprod-db-vpc-1"
  description = "Allows all communication into the non-production db vpc from eks-kosha-staging"
  vpc_id = data.aws_vpc.requestor_vpc.id
}

# security group rules because the rules are going to reference the groups
resource "aws_security_group_rule" "nonprod-db-vpc-1-to-eks-kosha-staging" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = aws_security_group.nonprod-db-vpc-1-to-eks-kosha-staging.id
  source_security_group_id = aws_security_group.eks-kosha-staging-to-nonprod-db-vpc-1.id
}

resource "aws_security_group_rule" "eks-kosha-staging-to-nonprod-db-vpc-1" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = aws_security_group.eks-kosha-staging-to-nonprod-db-vpc-1.id
  source_security_group_id = aws_security_group.nonprod-db-vpc-1-to-eks-kosha-staging.id
}