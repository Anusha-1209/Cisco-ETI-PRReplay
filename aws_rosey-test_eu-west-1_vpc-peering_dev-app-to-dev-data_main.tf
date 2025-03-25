provider "vault" {
    alias     = "eticloud"
    address   = "https://keeper.cisco.com"
    namespace = "eticloud"
}

locals {
  aws_region         = "eu-west-1"
  aws_account_name   = "rosey-test" 
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-nonprod"                                                  
    key     = "terraform-state/aws/rosey-test/eu-west-1/vpc-peering/dev-app-to-data.tfstate" 
    region  = "us-east-2"                                                                 
  }
}

# Get the VPC IDs based on the names of the VPCs
data "aws_vpc" "acceptor_vpc" {
  filter {
    name   = "tag:Name"
    values = ["rosey-dev-euw1-1"]
  }
}

data "aws_vpc" "requestor_vpc" {
  filter {
    name   = "tag:Name"
    values = ["rosey-dev-data-euw1-1"]
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
  region      = local.aws_region
  max_retries = 3
}

# VPC peering resources
resource "aws_vpc_peering_connection" "dev-data-to-app" {
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
    Name               = "VPC Peering between rosey-dev-euw1-1 and rosey-dev-data-euw1-1"
    ApplicationName    = "dev-data-to-app-peering"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "Prod"
    ResourceOwner      = "ETI SRE"
  }
}

# VPC routing resources
resource "aws_route" "data-to-app" {
  count                     = length(data.aws_route_tables.requestor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.requestor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.acceptor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.dev-data-to-app.id
}

resource "aws_route" "app-to-data" {
  count                     = length(data.aws_route_tables.acceptor_vpc_rt.ids)
  route_table_id            = data.aws_route_tables.acceptor_vpc_rt.ids[count.index]
  destination_cidr_block    = data.aws_vpc.requestor_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.dev-data-to-app.id
}

# security groups

# resource "aws_security_group" "dev-data-vpc-to-app-vpc" {
#   name = "dev-data-vpc-to-app"
#   description = "Allows all communication into app from the dev data vpc"
#   vpc_id = data.aws_vpc.acceptor_vpc.id
# }

# resource "aws_security_group" "app-dev-to-data-vpc" {
#   name = "app-to-dev-data-vpc"
#   description = "Allows all communication into the dev data vpc from app"
#   vpc_id = data.aws_vpc.requestor_vpc.id
# }

# # security group rules because the rules are going to reference the groups
# resource "aws_security_group_rule" "dev-data-vpc-to-app" {
#   type = "ingress"
#   from_port = 0
#   to_port = 65535
#   protocol = "-1"
#   security_group_id = aws_security_group.dev-data-vpc-to-app-vpc.id
#   source_security_group_id = aws_security_group.app-dev-to-data-vpc.id
# }

# resource "aws_security_group_rule" "app-to-dev-data-vpc" {
#   type = "ingress"
#   from_port = 0
#   to_port = 65535
#   protocol = "-1"
#   security_group_id = aws_security_group.app-dev-to-data-vpc.id
#   source_security_group_id = aws_security_group.dev-data-vpc-to-app-vpc.id
# }

data "aws_security_groups" "eks_cluster_sg" {
  filter {
    name   = "group-name"
    values = ["eks-cluster-sg-rosey-dev-euw1-1-1786136631"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.acceptor_vpc.id]
  }
}

data "aws_security_groups" "es_cluster_sg" {
  filter {
    name = "group-name"
    values = ["rosey-dev-data-sg-euw1-1"]
  }
    filter {
    name   = "vpc-id"
    values = [data.aws_vpc.requestor_vpc.id]
  }
}

# security group rules because the rules are going to reference the groups
resource "aws_security_group_rule" "dev-data-vpc-to-app" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = data.aws_security_groups.es_cluster_sg.ids[0]
  source_security_group_id = data.aws_security_groups.eks_cluster_sg.ids[0]
}

resource "aws_security_group_rule" "app-to-dev-data-vpc" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  security_group_id = data.aws_security_groups.eks_cluster_sg.ids[0]
  source_security_group_id = data.aws_security_groups.es_cluster_sg.ids[0]
} 