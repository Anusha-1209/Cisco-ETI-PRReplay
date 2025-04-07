terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-apisec-dev/elasticache/us-east-2/redis-apisec-pr-1.tfstate"
    region = "us-east-2"
  }
}

locals {
  # VPC module creates this, there is no way to grab it from the module,
  # so you need to make sure the naming convention is consistent
  subnet_group_name    = "redis-apisec-pr-1-vpc-ec-subnet-group"
  elasticache_name     = "redis-apisec-pr-1"
  redis_vpc_name       = "redis-apisec-pr-1-vpc"
  eks_cluster_vpc_name = "apisec-pr-1-vpc"
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
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/apisec-dev/terraform_admin"
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
  name = "redis-apisec-pr-1-sg"
  vpc_id = data.aws_vpc.redis_vpc.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks     = [data.aws_vpc.cluster_vpc.cidr_block]
  }
}

# Create an ElastiCache replication group
resource "aws_elasticache_replication_group" "redis-elastic-cache" {
  replication_group_id          = local.elasticache_name
  description                   = "Redis replication group for ${local.elasticache_name}"
  replicas_per_node_group       = 1
  num_node_groups               = 2
  node_type                     = "cache.r7g.large"
  engine                        = "redis"
  engine_version                = "7.1"
  port                          = 6379
  automatic_failover_enabled    = true
  at_rest_encryption_enabled    = true
  multi_az_enabled              = true
  transit_encryption_enabled    = true
  subnet_group_name             = local.subnet_group_name
  security_group_ids            = [aws_security_group.redis_security_group.id]
}