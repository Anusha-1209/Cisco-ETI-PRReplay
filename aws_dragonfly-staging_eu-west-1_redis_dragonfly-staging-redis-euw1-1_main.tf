terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-nonprod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/aws-dragonfly-staging-1/eu-west-1/redis/dragonfly-staging-redis-euw1-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2" # DO NOT CHANGE.
  }
}

locals {
  name              = "dragonfly-staging-euw1-1"
  eks_vpc_name      = "dragonfly-compute-staging-1-vpc"
  data_vpc_name     = "dragonfly-data-staging-1-vpc"
  region            = "eu-west-1"
  aws_account_name  = "dragonfly-staging"
  node_type         = "cache.t2.small"
  subnet_group_name = "dragonfly-staging-data-sg-euw1-1"
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider    = vault.eticloud
  path        = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = local.region
}

data "aws_vpc" "cluster_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.eks_vpc_name]
  }
}

data "aws_vpc" "redis_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.data_vpc_name]
  }
}

data "aws_subnets" "redis_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.redis_vpc.id]
  }
  tags = {
    Name = "*private*"
  }
}

# Create a subnet group for the Elasticache service
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = local.subnet_group_name
  subnet_ids = data.aws_subnets.redis_subnets.ids
}

# Create a security group for the Elasticache service
resource "aws_security_group" "redis_security_group" {
  name   = local.subnet_group_name
  vpc_id = data.aws_vpc.redis_vpc.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    cidr_blocks     = [data.aws_vpc.cluster_vpc.cidr_block]
  }
}

resource "aws_elasticache_replication_group" "dragonfly-dev-euw1-1" {
  replication_group_id       = local.name
  description                = "Redis cluster ElastiCache"
  engine                     = "redis"
  engine_version             = "7.1"

  node_type                  = local.node_type
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