module "pipeline_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role = true

  role_name        = "${var.domain_name}-pipeline-role"
  role_description = "IAM Role to be assumed by Opensearch ingestion pipeline"

  trusted_role_services = [
    "osis-pipelines.amazonaws.com",
  ]

  role_requires_mfa       = false
  custom_role_policy_arns = [
    module.pipeline_opensearch_policy.arn,
    module.pipeline_kafka_policy.arn,
  ]

  tags = var.tags
}

module "pipeline_opensearch_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  create_policy = true

  name        = "${var.domain_name}-ingestion-policy"
  path        = "/"
  description = "IAM Policy for Opensearch ingestion"
  policy      = data.aws_iam_policy_document.pipeline_opensearch.json

  tags = var.tags
}

module "pipeline_kafka_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  create_policy = true

  name        = "${var.domain_name}-kafka-consumer-policy"
  path        = "/"
  description = "IAM Policy for Kafka consumer"
  policy      = data.aws_iam_policy_document.pipeline_kafka.json

  tags = var.tags
}
