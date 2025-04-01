data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_id}",
      ]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      values = ["sts.amazonaws.com"]
      variable = "${local.oidc_id}:aud"
    }
    condition {
      test     = "StringEquals"
      values = ["system:serviceaccount:${local.service_account}"]
      variable = "${local.oidc_id}:sub"
    }
  }
}

data "aws_iam_policy_document" "policy" {
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

resource "aws_iam_policy" "kafka_connect_policy" {
  name        = "${local.cluster_name}-streaman-kafkaconnect-policy"
  description = "${local.cluster_name} policy for streaman role"
  policy = templatefile(
    "${path.module}/resources/msk-connect-policy.json", {
      kakfa_connect_arangodb_logs_bucket    = data.aws_s3_bucket.mskconnect_logs_bucket.arn
      kakfa_connect_arangodb_execution_role = data.aws_iam_role.mskconnect_arangodb_execution_role.arn
      dragonly_binaries_bucket              = data.aws_s3_bucket.mskconnect_custom_plugin_bucket.arn
  })
}

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    sid = "lightspin sqs access"

    actions = [
      "sqs:*"
    ]
    resources = [
      "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dragonfly-sqs-dev-1.fifo"
    ]
  }
}
resource "aws_iam_policy" "lightspin_sqs_policy" {
  name        = "${local.cluster_name}-streaman-lightspin-sqs"
  description = "${local.cluster_name} policy for streaman role"
  policy      = data.aws_iam_policy_document.sqs_policy.json
}

resource "aws_iam_role" "role" {
  name        = local.role_name
  description = local.role_description

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "kafka_policy" {
  name        = "${local.cluster_name}-streaman-connector-writer-policy"
  description = "Policies for streaman role"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "dragonfly_msk_argo_writer_policy_attachment" {
  for_each = {
    kafka-policy = aws_iam_policy.kafka_policy.arn,
    kafka-connect-policy = aws_iam_policy.kafka_connect_policy.arn
    lightspin-sqs-policy = aws_iam_policy.lightspin_sqs_policy.arn
  }

  role       = aws_iam_role.role.name
  policy_arn = each.value
}