# AWS credentials
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-prod/terraform_admin"
  provider = vault.eticloud
}

# OS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# OS domain
data "aws_opensearch_domain" "dragonfly_prod_eu_1_os" {
  domain_name = var.domain_name
}

# MSK cluster
data "aws_msk_cluster" "dragonfly_msk_eu1" {
  cluster_name = var.msk_cluster_name
}

data "aws_iam_policy_document" "pipeline_opensearch" {
  statement {
    effect  = "Allow"
    actions = ["es:DescribeDomain"]
    resources = [
      data.aws_opensearch_domain.dragonfly_prod_eu_1_os.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "es:ESHttp*",
    ]
    resources = [
      "${data.aws_opensearch_domain.dragonfly_prod_eu_1_os.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "pipeline_kafka" {
  statement {
    effect  = "Allow"
    actions = ["es:DescribeDomain"]
    resources = [
      data.aws_opensearch_domain.dragonfly_prod_eu_1_os.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:AlterCluster",
      "kafka-cluster:DescribeCluster",
      "kafka:DescribeClusterV2",
      "kafka:GetBootstrapBrokers",
    ]
    resources = [
      data.aws_msk_cluster.dragonfly_msk_eu1.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:*Topic*",
      "kafka-cluster:ReadData",
    ]
    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${var.msk_cluster_name}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup"
    ]
    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${var.msk_cluster_name}/*",
    ]
  }
}
