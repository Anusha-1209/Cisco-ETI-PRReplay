resource "aws_iam_role" "msk_connect_kg_execution_role" {
  name = "dragonfly-kg-connector-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" = "Allow",
        "Principal" : {
          "Service" = "kafkaconnect.amazonaws.com"
        },
        "Action" = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "msk_connect_kg_role_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:AlterCluster",
      "kafka-cluster:DescribeCluster",
      "kafka:DescribeClusterV2",
      "kafka:GetBootstrapBrokers"
    ]

    resources = [
      data.aws_msk_cluster.dragonfly_msk_1.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kafka-cluster:*Topic*",
      "kafka-cluster:ReadData"
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/*",
    ]
  }

  statement {
    actions = [
      "kafka-cluster:CreateTopic",
      "kafka-cluster:WriteData",
      "kafka-cluster:ReadData",
      "kafka-cluster:DescribeTopic"
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/__amazon_msk_connect_*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup"
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/__amazon_msk_connect_*",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/connect-*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:DescribeLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries"
    ]

    resources = [
      aws_cloudwatch_log_group.dragonfly_kg_connector.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.arangodb_connector_logs_bucket}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = [
      aws_secretsmanager_secret.msk_connect_kg.arn
    ]
  }

  // kms access
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.encryption_key.arn
    ]
  }
}

resource "aws_iam_policy" "role_policy" {
  name        = "dragonfly-kg-connector-role-policy"
  description = "Policies for arangodb connector role"
  policy      = data.aws_iam_policy_document.msk_connect_kg_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.msk_connect_kg_execution_role.name
  policy_arn = aws_iam_policy.role_policy.arn
}
