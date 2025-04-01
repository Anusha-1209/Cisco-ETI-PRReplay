resource "aws_iam_role" "dragonfly_streaman" {
  name = "${local.cluster_name}-streaman-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_id}:aud" : "sts.amazonaws.com",
            "${local.oidc_id}:sub" : "system:serviceaccount:${local.dragonfly_streaman_service_account}"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

data "aws_iam_policy_document" "dragonfly_streaman_kafka_policy" {
  statement {
    sid = "access"

    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:AlterCluster",
      "kafka-cluster:DescribeCluster",
      "kafka:DescribeClusterV2",
      "kafka:GetBootstrapBrokers",
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}"
    ]
  }

  statement {
    sid = "kafkawriter"

    actions = [
      "kafka-cluster:*Topic*",
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/kg-node*",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/kg-edge*",
    ]
  }

  statement {
    sid = "kafkareader"

    actions = [
      "kafka-cluster:*Topic*",
      "kafka-cluster:ReadData",
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.id}/falco",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.id}/monitoring",
    ]
  }

  statement {
    sid = "kafkagroupreader"

    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup",
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.id}/*",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.id}/*",
    ]
  }
}

resource "aws_iam_policy" "dragonfly_streaman_kafka_policy" {
  name        = "${local.cluster_name}-streaman-connector-writer-policy"
  description = "Policies for streaman role"
  policy      = data.aws_iam_policy_document.dragonfly_streaman_kafka_policy.json
}

resource "aws_iam_policy" "dragonfly_streaman_kafkconnect_policy" {
  name        = "${local.cluster_name}-streaman-kafkaconnect-polic"
  description = "${local.cluster_name} policy for streaman role"
  policy = templatefile(
    "${path.module}/resources/msk-connect-policy.json", {
      kakfa_connect_arangodb_logs_bucket    = data.aws_s3_bucket.mskconnect_logs_bucket.arn
      kakfa_connect_arangodb_execution_role = data.aws_iam_role.mskconnect_arangodb_execution_role.arn
      dragonly_binaries_bucket              = data.aws_s3_bucket.mskconnect_custom_plugin_bucket.arn
  })
}

resource "aws_iam_role_policy_attachment" "dragonfly_streaman_policy_attachment" {
  for_each = {
    kafka-policy = aws_iam_policy.dragonfly_streaman_kafka_policy.arn,
    kafka-connect-policy = aws_iam_policy.dragonfly_streaman_kafkconnect_policy.arn
  }

  role       = aws_iam_role.dragonfly_streaman.name
  policy_arn = each.value
}

