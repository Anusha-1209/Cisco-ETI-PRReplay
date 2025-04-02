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
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}"
    ]

    effect = "Allow"
  }

  statement {
    sid = "topic"

    actions = [
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:ReadData",
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/monitoring*",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/falco*",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/threat*",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/attack*",
    ]

    effect = "Allow"
  }

  statement {
    sid = "groups"

    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup",
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/event-manager",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role" "role" {
  name        = local.role_name
  description = local.role_description

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  inline_policy {
    name   = "kserve-inference-policy"
    policy = data.aws_iam_policy_document.policy.json
  }

  managed_policy_arns = []
}

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    sid = "PortshiftSQSAccess"

    actions = [
      "sqs:*"
    ]
    resources = [
      "arn:aws:sqs:us-east-1:975854676552:queue-eventsForwarderTopic-lightspin"
    ]
  }
}
resource "aws_iam_policy" "portshift_sqs_policy" {
  name        = "${local.cluster_name}-streaman-portshift-sqs"
  description = "${local.cluster_name} policy for event manager role"
  policy      = data.aws_iam_policy_document.sqs_policy.json
}

resource "aws_iam_role_policy_attachment" "dragonfly_event_manager_sqs_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.portshift_sqs_policy.arn
}
