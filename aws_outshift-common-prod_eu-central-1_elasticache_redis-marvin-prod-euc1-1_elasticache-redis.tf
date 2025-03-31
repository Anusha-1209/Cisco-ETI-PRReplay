terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/outshift-common-prod/elasticache/eu-central-1/redis-marvin-prod-euc1-1.tfstate"
    region = "eu-central-1"
  }
}

locals {
  # VPC module creates this, there is no way to grab it from the module,
  # so you need to make sure the naming convention is consistent
  subnet_group_name    = "marvin-prod-euc1-data-ec-subnet-group"
  elasticache_name     = "marvin-redis-prod-euc1-1"
  redis_vpc_name   = "marvin-prod-euc1-data"
  eks_cluster_vpc_name = "marvin-prod-euc1-1"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "eu-central-1"
  default_tags {
    tags = {
      ApplicationName    = local.elasticache_name
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "prod"
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
  path     = "secret/infra/aws/outshift-common-prod/terraform_admin"
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
  name = "redis-marvin-prod-euc1-1-sg"
  vpc_id = data.aws_vpc.redis_vpc.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks     = [data.aws_vpc.cluster_vpc.cidr_block]
  }
}

resource "aws_elasticache_replication_group" "redis-marvin-prod-euc1-1" {
  replication_group_id       = local.elasticache_name
  description                = "Redis cluster ElastiCache"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.m4.large"
  port                       = 6379
  parameter_group_name       = "default.redis7.cluster.on"
  automatic_failover_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  num_node_groups            = 1
  replicas_per_node_group    = 1

  subnet_group_name          = local.subnet_group_name
  security_group_ids         = [aws_security_group.redis_security_group.id]
}
