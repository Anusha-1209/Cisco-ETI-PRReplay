terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/outshift-common-dev/elasticache/us-east-2/redis-marvin-dev-use2-1.tfstate"
    region = "us-east-2"
  }
}

locals {
  # VPC module creates this, there is no way to grab it from the module,
  # so you need to make sure the naming convention is consistent
  subnet_group_name    = "marvin-dev-use2-data-ec-subnet-group"
  elasticache_name     = "marvin-redis-dev-use2-1"
  redis_vpc_name   = "marvin-dev-use2-data"
  eks_cluster_vpc_name = "marvin-dev-use2-1"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
  default_tags {
    tags = {
      ApplicationName    = local.elasticache_name
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/outshift-common-dev/terraform_admin"
  provider = vault.eticloud
}

data "aws_vpc" "cluster_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.eks_cluster_vpc_name]
  }
}

data "aws_vpc" "redis_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.redis_vpc_name]
  }
}

# Create a security group for the Elasticache service
resource "aws_security_group" "redis_security_group" {
  name = "redis-marvin-dev-use2-1-sg"
  vpc_id = data.aws_vpc.redis_vpc.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks     = [data.aws_vpc.cluster_vpc.cidr_block]
  }
}

resource "aws_elasticache_cluster" "redis-elastic-cache" {
  cluster_id           = local.elasticache_name
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  port                 = 6379
  engine_version       = "3.2.10"
  subnet_group_name             = local.subnet_group_name
  security_group_ids            = [aws_security_group.redis_security_group.id]
}

