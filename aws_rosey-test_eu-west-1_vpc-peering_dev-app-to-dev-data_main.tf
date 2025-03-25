terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"                                                  
    key     = "terraform-state/aws/rosey-test/eu-west-1/vpc-peering/dev-app-to-data.tfstate" 
    region  = "us-east-2"                                                                 
  }
}

locals {
  aws_region         = "eu-west-1"
  app_name           = "rosey-dev" 
  aws_account_name   = "rosey-test" 
}

################################################################################
# Provider configuration
################################################################################
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = local.aws_region
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = local.app_name
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["rosey-dev-euw1-1"]
  }
}

data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:ApplicationName"
    values = ["rosey-dev-data-euw1-1"]
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


# VPC peering resources
resource "aws_vpc_peering_connection" "app_to_data" {
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
    Name                  = "VPC Peering between rosey-dev-euw1-1 and rosey-dev-data-euw1-1"
    CSBApplicationName    = "dev-app-dev-data-peering"
    CSBCiscoMailAlias     = "eti-sre@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy       = "Cisco Operations Data"
    CSBEnvironment        = "NonProd"
    CSBResourceOwner      = "Outshift SRE"
  }
}

# VPC routing resources
resource "aws_route" "app_to_data" {
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.data_to_app.id
}

resource "aws_route" "data_to_app" {
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_data.id
}

# Security groups
resource "aws_security_group" "app_to_data" {
  name        = "app-vpc-to-data-vpc"
  description = "Allows all communication into data-pvc from the app-pvc"
  vpc_id      = data.aws_vpc.acceptor_vpc.id
}

resource "aws_security_group" "data_to_app" {
  name        = "data-vpc-to-app-vpc"
  description = "Allows all communication into app-pvc from the data-pvc"
  vpc_id      = data.aws_vpc.requestor_vpc.id
}

# security group rules because the rules are going to reference the groups
resource "aws_security_group_rule" "app_to_data" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.app_to_data.id
  source_security_group_id = aws_security_group.data_to_app.id
}

resource "aws_security_group_rule" "data_to_app" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.data_to_app.id
  source_security_group_id = aws_security_group.app_to_data.id
}
