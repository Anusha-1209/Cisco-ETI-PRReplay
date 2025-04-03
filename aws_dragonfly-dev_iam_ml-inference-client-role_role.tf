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
      values = local.service_accounts
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
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/kg-node*",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/kg-edge*",
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
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/*",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role" "role" {
  name        = local.role_name
  description = local.role_description

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  inline_policy {
    name   = "inference-client-policy"
    policy = data.aws_iam_policy_document.policy.json
  }

  managed_policy_arns = []
}
