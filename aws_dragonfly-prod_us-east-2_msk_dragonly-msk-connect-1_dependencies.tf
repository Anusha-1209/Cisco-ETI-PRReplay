data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
  provider = vault.eticloud
}

// account information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

// Arangodb secrets from vault
data "vault_generic_secret" "arangodb_secrets" {
  path     = "secret/prod/us-east-2/thrill-arangodb"
  provider = vault.dragonfly
}

// kafka cluster information
data "aws_msk_cluster" "dragonfly_msk_1" {
  cluster_name = "dragonfly-msk-prod-1"
}

// data vpc information
data "aws_vpc" "msk_vpc" {
  filter {
    name = "tag:Name"
    values = [
      local.data_vpc
    ]
  }
}

// data subnets information
data "aws_subnets" "msk_subnets" {
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.msk_vpc.id
    ]
  }
  tags = {
    Tier = "Private"
  }
}

// compute vpc information
data "aws_vpc" "eks_vpc" {
  filter {
    name = "tag:Name"
    values = [
      local.compute_vpc
    ]
  }
}

// compute subnets information
data "aws_subnets" "eks_subnets" {
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.eks_vpc.id
    ]
  }
  tags = {
    Tier = "Private"
  }
}

// bucket containing the custom plugin jar
data "aws_s3_bucket" "mskconnect_custom_plugin_bucket" {
  bucket = local.arangodb_connector_plugin_bucket
}

// Jar object in the bucket
data "aws_s3_object" "mskconnect_custom_plugin_jar" {
  bucket = data.aws_s3_bucket.mskconnect_custom_plugin_bucket.bucket
  key    = local.arangodb_connector_plugin_jar
}
