data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
  provider = vault.eticloud
}

// account information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "compute_vpc" {
  filter {
    name = "tag:Name"
    values = [
      local.vpc_id
    ]
  }
}

data "aws_subnets" "compute_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.compute_vpc.id]
  }
  tags = {
    Tier = "Private"
  }
}

data "aws_msk_cluster" "dragonfly_msk_1" {
  cluster_name = local.dragonfly_msk_cluster_name
}

// EKS
data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_s3_bucket" "mskconnect_custom_plugin_bucket" {
  bucket = local.arango_connector_plugin_bucket
}

data "aws_s3_bucket" "mskconnect_logs_bucket" {
  bucket = local.arangodb_connector_logs_bucket
}

data "aws_iam_role" "mskconnect_arangodb_execution_role" {
  name = local.arangodb_connector_execution_role
}