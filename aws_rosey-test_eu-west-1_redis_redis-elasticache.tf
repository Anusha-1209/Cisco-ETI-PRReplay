terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-nonprod"                                                   # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/rosey-test/eu-west-1/redis/rosey-dev-euw1-1.tfstate"       # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"                                                                   # DO NOT CHANGE.

  }
}
locals {
  name = "rosey-dev-euw1-1"
  region = "eu-west-1"
  aws_account_name = "rosey-test"
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

resource "aws_elasticache_replication_group" "rosey-dev-euw1-1" {
  replication_group_id       = "rosey-dev-euw1-1"
  description                = "Redis cluster for rosey-dev-euw1-1 ElastiCache"
  engine                     = "redis"
  engine_version             = "7.1"

  node_type                  = "cache.t2.medium"
  port                       = 6379
  parameter_group_name       = "default.redis7.cluster.on"
  automatic_failover_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  num_node_groups            = 2
  replicas_per_node_group    = 1
}
