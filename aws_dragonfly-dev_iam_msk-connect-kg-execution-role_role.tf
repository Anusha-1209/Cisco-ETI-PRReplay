resource "aws_iam_role" "role" {
  for_each = local.regions

  name = "dragonfly-kg-connector-role-${each.key}"
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

data "aws_iam_policy_document" "role_policy_document" {
  for_each = local.regions

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
      "arn:aws:kafka:${each.value}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/*",
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
      "arn:aws:kafka:${each.value}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/__amazon_msk_connect_*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup"
    ]

    resources = [
      "arn:aws:kafka:${each.value}:${data.aws_caller_identity.current.account_id}:group/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/__amazon_msk_connect_*",
      "arn:aws:kafka:${each.value}:${data.aws_caller_identity.current.account_id}:group/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/connect-*",
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

resource "aws_iam_policy" "role_policy" {
  for_each = local.regions

  name        = "dragonfly-kg-connector-role-policy-${each.key}"
  description = "Policies for arangodb connector role in ${each.value}"
  policy      = data.aws_iam_policy_document.role_policy_document[each.key].json
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  for_each = local.regions

  role       = aws_iam_role.role[each.key].name
  policy_arn = aws_iam_policy.role_policy[each.key].arn
}
