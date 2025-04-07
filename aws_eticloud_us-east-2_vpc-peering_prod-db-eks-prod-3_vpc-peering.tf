# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".
provider "vault" {
    alias     = "eticcprod"
    address   = "https://keeper.cisco.com"
    namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path = "secret/eticcprod/infra/prod/aws"
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"                                                                               # Do not change without talking to the SRE team.
    key    = "terraform-state/vpc-peering/us-east-2/prod-db-eks-prod-3/prod-db-eks-prod-3.tfstate" # The statefile name should be descriptive and must be unique.
    region = "us-east-2"                                                                                               # Do not change without talking to the SRE team.
  }
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:Name"
    values = ["eks-prod-3"]
  }
}

data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:Name"
    values = ["prod-db-vpc-1"]
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
resource "aws_vpc_peering_connection" "prod-db-eks-prod-3" {
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
    Name               = "VPC Peering between eks-prod-3 and prod-db-vpc-1"
    ApplicationName    = "prod-db-eks-prod-3-peering"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "Prod"
    ResourceOwner      = "ETI SRE"
  }
}

# VPC routing resources
resource "aws_route" "db-to-prod" {
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prod-db-eks-prod-3.id
}

resource "aws_route" "prod-to-db" {
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prod-db-eks-prod-3.id
}

# security groups

resource "aws_security_group" "prod-db-vpc-1-to-eks-prod-3" {
  name = "prod-db-vpc-1-to-eks-prod-3"
  description = "Allows all communication into eks-prod-3 from the production db vpc"
  vpc_id = data.aws_vpc.acceptor_vpc.id
}

resource "aws_security_group" "eks-prod-3-to-prod-db-vpc-1" {
  name = "eks-prod-3-to-prod-db-vpc-1"
  description = "Allows all communication into the production db vpc from eks-prod-3"
  vpc_id = data.aws_vpc.requestor_vpc.id
}

# security group rules because the rules are going to reference the groups
resource "aws_security_group_rule" "prod-db-vpc-1-to-eks-prod-3" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = aws_security_group.prod-db-vpc-1-to-eks-prod-3.id
  source_security_group_id = aws_security_group.eks-prod-3-to-prod-db-vpc-1.id
}

resource "aws_security_group_rule" "eks-prod-3-to-prod-db-vpc-1" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = aws_security_group.eks-prod-3-to-prod-db-vpc-1.id
  source_security_group_id = aws_security_group.prod-db-vpc-1-to-eks-prod-3.id
}
