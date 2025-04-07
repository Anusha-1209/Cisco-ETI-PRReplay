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
    bucket = "eticloud-tf-state-prod"                                                                    # Do not change without talking to the SRE team.
    key    = "terraform-state/vpc-peering/us-east-2/prod-db-eks-prod-4/prod-db-eks-prod-4.tfstate"       # The statefile name should be descriptive and must be unique.
    region = "us-east-2"                                                                                 # Do not change without talking to the SRE team.
  }
}

data "aws_vpc" "acceptor_vpc" {
  provider = aws.us-west-2
  filter {
    name   = "tag:Name"
    values = ["eks-prod-4-vpc"]
  }
}

data "aws_vpc" "requestor_vpc" {
  provider = aws.us-east-2
  filter {
    name   = "tag:Name"
    values = ["prod-db-vpc-1"]
  }
}

data "aws_route_tables" "acceptor_vpc_rt" {
  provider = aws.us-west-2
  vpc_id = data.aws_vpc.acceptor_vpc.id
}

data "aws_route_tables" "requestor_vpc_rt" {
  provider = aws.us-east-2
  vpc_id = data.aws_vpc.requestor_vpc.id
}

# Use this to get the account ID
data "aws_caller_identity" "current" {
    provider = aws.us-east-2
}


data "aws_eks_cluster" "this" {
  provider = aws.us-west-2
  name = "eks-prod-4"
}

data "aws_rds_cluster" "this" {  
  provider = aws.us-east-2
  cluster_identifier = "rds-prod-1"
}
locals {
  acceptor_vpc_id = data.aws_vpc.acceptor_vpc.id
  acceptor_vpc_cidr_block = data.aws_vpc.acceptor_vpc.cidr_block
  acceptor_vpc_rt_ids = data.aws_route_tables.acceptor_vpc_rt.ids
  eks_cluster_sg_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  requestor_vpc_cidr_block = data.aws_vpc.requestor_vpc.cidr_block
}

# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  alias = "us-east-2"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}
provider "aws" {
  alias = "us-west-2"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region = "us-west-2"
}

# VPC peering resources
resource "aws_vpc_peering_connection" "prod-db-eks-prod-4" {
  provider = aws.us-east-2
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = local.acceptor_vpc_id
  vpc_id        = data.aws_vpc.requestor_vpc.id
  auto_accept   = false
  peer_region = "us-west-2"

  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }

  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }
    tags = {
    Name                  = "VPC Peering between eks-prod-4 and prod-db-vpc-1"
    CSBApplicationName    = "prod-db-eks-prod-4-peering"
    CSBCiscoMailAlias     = "eti-sre-admins@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy       = "Cisco Operations Data"
    CSBEnvironment        = "Prod"
    CSBResourceOwner      = "ETI SRE"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider = aws.us-west-2
  vpc_peering_connection_id = aws_vpc_peering_connection.prod-db-eks-prod-4.id
  auto_accept = true
   tags = {
    Name                  = "VPC Peering between eks-prod-4 and prod-db-vpc-1"
    CSBApplicationName    = "prod-db-eks-prod-4-peering"
    CSBCiscoMailAlias     = "eti-sre-admins@cisco.com"
    CSBDataClassification = "Cisco Confidential"
    CSBDataTaxonomy       = "Cisco Operations Data"
    CSBEnvironment        = "Prod"
    CSBResourceOwner      = "ETI SRE"
  }
  depends_on = [
    aws_vpc_peering_connection.prod-db-eks-prod-4,
  ]
}

# VPC routing resources
resource "aws_route" "db-to-eks" {
  provider = aws.us-east-2
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = local.acceptor_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prod-db-eks-prod-4.id
}

resource "aws_route" "eks-to-db" {
  provider = aws.us-west-2
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = local.requestor_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prod-db-eks-prod-4.id
}



output "eks_sg" {
  value = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}
output "rds_sg" {
  value = tolist(data.aws_rds_cluster.this.vpc_security_group_ids)[1]
}
resource "aws_security_group_rule" "into_rds" {
  provider = aws.us-east-2
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = tolist(data.aws_rds_cluster.this.vpc_security_group_ids)[1]
  cidr_blocks = [local.acceptor_vpc_cidr_block]
}

resource "aws_security_group_rule" "into_eks" {
  provider = aws.us-west-2
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = local.eks_cluster_sg_id
  cidr_blocks = [local.requestor_vpc_cidr_block]
}
