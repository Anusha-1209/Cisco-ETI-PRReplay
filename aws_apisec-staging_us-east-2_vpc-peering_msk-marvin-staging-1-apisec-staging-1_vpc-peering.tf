terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-apisec-staging/vpc-peering/us-east-2/msk-marvin-staging-1-apisec-staging-1/vpc-peering.tfstate"
    region = "us-east-2"
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/apisec-staging/terraform_admin"
  provider = vault.eticloud
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:Name"
    values = ["apisec-staging-1-vpc"]
  }
}

data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:Name"
    values = ["msk-marvin-staging-1-vpc"]
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
  region      = "us-east-2"
  max_retries = 3
}

# VPC peering resources
resource "aws_vpc_peering_connection" "msk_to_marvin" {
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
    Name               = "VPC Peering between apisec-staging-1-vpc and msk-marvin-staging-vpc-1"
    ApplicationName    = "msk-marvin-staging-1-apisec-staging-1"
    CiscoMailAlias     = "eti-sre@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "ETI SRE"
  }
}

# VPC routing resources
resource "aws_route" "marvin_to_msk" {
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.msk_to_marvin.id
}

resource "aws_route" "msk_to_marvin" {
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.msk_to_marvin.id
}

# Security groups
resource "aws_security_group" "marvin_to_msk" {
  name        = "marvin-staging-vpc-1-to-msk-marvin-staging-vpc-1"
  description = "Allows all communication into msk-marvin-staging-vpc-1 from the marvin-staging-vpc-1"
  vpc_id      = data.aws_vpc.acceptor_vpc.id
}

resource "aws_security_group" "msk_to_marvin" {
  name        = "msk-marvin-staging-vpc-1-to-marvin-staging-vpc-1"
  description = "Allows all communication into marvin-staging-vpc-1 from the msk-marvin-staging-vpc-1"
  vpc_id      = data.aws_vpc.requestor_vpc.id
}

# security group rules because the rules are going to reference the groups
resource "aws_security_group_rule" "marvin_to_msk" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.marvin_to_msk.id
  source_security_group_id = aws_security_group.msk_to_marvin.id
}

resource "aws_security_group_rule" "msk_to_marvin" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.msk_to_marvin.id
  source_security_group_id = aws_security_group.marvin_to_msk.id
}
