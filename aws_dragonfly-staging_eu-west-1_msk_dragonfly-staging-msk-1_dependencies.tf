data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
  provider = vault.eticloud
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "vault_generic_secret" "msk_auth_credentials" {
  for_each = var.kafka_clients

  path     = each.value.vault_path
  provider = vault.dragonfly
}

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
    values = ["dragonfly-compute-staging-1-vpc"]
  }
}

data "aws_vpc" "msk_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dragonfly-data-staging-1-vpc"]
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
