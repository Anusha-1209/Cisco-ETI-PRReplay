terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws/dragonfly-demo/eu-west-1/vpc-peering/demo-to-target/vpc-peering.tfstate"
    region = "us-east-2"
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/dragonfly-demo/terraform_admin"
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["dragonfly-demo-euw1-1"]
  }
}

data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["dragonfly-tgt-euw1-1"]
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
resource "aws_vpc_peering_connection" "demo_to_target" {
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
    Name                  = "VPC Peering between dragonfly-demo-euw1-1 and dragonfly-tgt-euw1-1"
    CSBApplicationName    = "demo-dragonfly-demo-target-peering"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy       = "Cisco Operations Data"
    CSBEnvironment        = "NonProd"
    CSBResourceOwner      = "Outshift SRE"
  }
}

# VPC routing resources
resource "aws_route" "demo_to_target" {
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.demo_to_target.id
}

resource "aws_route" "demo_to_target" {
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.demo_to_target.id
}

# Security groups
resource "aws_security_group" "demo_to_target" {
  name        = "demo-vpc-to-target-pvc"
  description = "Allows all communication into target-pvc from the demo-pvc"
  vpc_id      = data.aws_vpc.acceptor_vpc.id
}

resource "aws_security_group" "target_to_demo" {
  name        = "target-vpc-to-demo-pvc"
  description = "Allows all communication into demo-pvc from the target-pvc"
  vpc_id      = data.aws_vpc.requestor_vpc.id
}

# security group rules because the rules are going to reference the groups
resource "aws_security_group_rule" "demo_to_target" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.demo_to_target.id
  source_security_group_id = aws_security_group.target_to_demo.id
}

resource "aws_security_group_rule" "target_to_demo" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.target_to_demo.id
  source_security_group_id = aws_security_group.demo_to_target.id
}
