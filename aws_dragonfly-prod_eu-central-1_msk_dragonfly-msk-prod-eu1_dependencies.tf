data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-prod/terraform_admin"
  provider = vault.eticloud
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "msk_secret_policy" {
  for_each = var.kafka_clients

  statement {
    sid    = "AWSKafkaResourcePolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }

    actions   = ["secretsmanager:getSecretValue"]
    resources = [aws_secretsmanager_secret.msk_auth_credentials[each.key].arn]
  }
}

data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-prod-euc1-1"]
  }
}

data "aws_vpc" "msk_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-prod-data-euc1-1"]
  }
}

data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
  tags = {
    Tier = "Private"
  }
}

data "aws_subnets" "msk_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.msk_vpc.id]
  }
  tags = {
    Tier = "Private"
  }
}

data "aws_s3_bucket" "mskconnect_custom_plugin_bucket" {
  bucket = local.arango_connector_plugin_bucket
  provider = aws.us-east-2
}

data "aws_s3_bucket" "mskconnect_logs_bucket" {
  bucket = local.arangodb_connector_logs_bucket
  provider = aws.us-east-2
}

data "aws_s3_object" "arangodb_connector_plugin_jar" {
  bucket = local.arango_connector_plugin_bucket
  key    = local.arangodb_connector_plugin_jar
}
