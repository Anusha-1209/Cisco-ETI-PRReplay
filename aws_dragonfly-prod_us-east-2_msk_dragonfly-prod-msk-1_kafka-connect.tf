resource "aws_mskconnect_custom_plugin" "plugin" {
  name = "${local.arango_connector_plugin_name}-plugin"
  content_type = "JAR"
  location {
    s3 {
      bucket_arn = data.aws_s3_bucket.mskconnect_custom_plugin_bucket.arn
      file_key = data.aws_s3_object.arangodb_connector_plugin_jar.key
    }
  }
}

resource "aws_iam_role" "connector_role" {
  name = "${local.arango_connector_plugin_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" = "Allow",
        "Principal": {
          "Service" = "kafkaconnect.amazonaws.com"
        },
        "Action" = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "connector_role_policy_document" {
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
      aws_msk_cluster.dragonfly_msk_1.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kafka-cluster:*Topic*",
      "kafka-cluster:ReadData"
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.dragonfly_msk_1.cluster_name}/${aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/*",
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
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.dragonfly_msk_1.cluster_name}/${aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/__amazon_msk_connect_*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup"
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${aws_msk_cluster.dragonfly_msk_1.cluster_name}/${aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/__amazon_msk_connect_*",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${aws_msk_cluster.dragonfly_msk_1.cluster_name}/${aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/connect-*",
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
      "*"
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
}

resource "aws_iam_policy" "connector_role_policy" {
  name        = "${local.arango_connector_plugin_name}-role-policy"
  description = "Policies for arangodb connector role"
  policy      = data.aws_iam_policy_document.connector_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "connector_role_policy_attachment" {
  role       = aws_iam_role.connector_role.name
  policy_arn = aws_iam_policy.connector_role_policy.arn
}

# Export useful information to Vault
resource "vault_generic_secret" "kafka_connect_vault" {
  path = "secret/prod/dragonfly-streaman/us/msk"

  data_json = jsonencode({
    mskCustomPluginArn = aws_mskconnect_custom_plugin.plugin.arn,
    mskCustomPluginRevision = aws_mskconnect_custom_plugin.plugin.latest_revision
    mskS3LogBucket = data.aws_s3_bucket.mskconnect_logs_bucket.bucket
    mskServiceExecutionRoleArn = aws_iam_role.connector_role.arn
    mskVpcSG = aws_security_group.dragonfly_msk_1.id
    mskVpcSubnets = join(",", data.aws_subnets.msk_subnets.ids)
  })

  provider = vault.dragonfly
}