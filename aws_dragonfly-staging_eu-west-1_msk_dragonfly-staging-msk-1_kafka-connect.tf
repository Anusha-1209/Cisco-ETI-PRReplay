resource "aws_iam_role" "connector_role" {
  name = "${local.connector_name}-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" = "Allow",
        "Principal" : {
          "Service" = "kafkaconnect.amazonaws.com"
        },
        "Action" = "sts:AssumeRole",
      }
    ]
  })
  force_detach_policies = true
}

data "aws_iam_policy_document" "connector_role_policy" {
  statement {
    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:AlterCluster",
      "kafka-cluster:DescribeCluster",
      "kafka:DescribeClusterV2",
      "kafka:GetBootstrapBrokers"
    ]

    resources = [
      "${aws_msk_cluster.dragonfly-msk-1.arn}:connector/*"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "kafka-cluster:*Topic*",
      "kafka-cluster:ReadData"
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.dragonfly-msk-1.cluster_name}/${aws_msk_cluster.dragonfly-msk-1.cluster_uuid}/*"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "kafka-cluster:CreateTopic",
      "kafka-cluster:WriteData",
      "kafka-cluster:ReadData",
      "kafka-cluster:DescribeTopic"
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.dragonfly-msk-1.cluster_name}/${aws_msk_cluster.dragonfly-msk-1.cluster_uuid}/__amazon_msk_connect_*"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup"
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${aws_msk_cluster.dragonfly-msk-1.cluster_name}/${aws_msk_cluster.dragonfly-msk-1.cluster_uuid}/*",
      # "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${aws_msk_cluster.dragonfly-msk-1.cluster_name}/${aws_msk_cluster.dragonfly-msk-1.cluster_uuid}/__amazon_msk_connect_*",
      # "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${aws_msk_cluster.dragonfly-msk-1.cluster_name}/${aws_msk_cluster.dragonfly-msk-1.cluster_uuid}/connect-*"
    ]

    effect = "Allow"
  }

  statement {
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

    effect = "Allow"
  }

  statement {
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.connector_name}-logs/*"
    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "connector_role_policy" {
  name        = "${local.connector_name}-role-policy"
  description = "Policies for msk connector"
  policy      = data.aws_iam_policy_document.connector_role_policy.json
}

resource "aws_iam_role_policy_attachment" "dragonfly_msk_connector_role_policy_attachment" {
  role       = aws_iam_role.connector_role.name
  policy_arn = aws_iam_policy.connector_role_policy.arn
}
