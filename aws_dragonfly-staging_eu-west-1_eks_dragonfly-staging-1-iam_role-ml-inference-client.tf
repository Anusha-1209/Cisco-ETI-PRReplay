resource "aws_iam_role" "dragonfly_ml_inferenceclient" {
  name = "ml-inferenceclient-role"

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
            "${local.oidc_id}:sub" : "system:serviceaccount:${local.dragonfly_ml_inference_client_service_account}"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

data "aws_iam_policy_document" "dragonfly_ml_inferenceclient_policies" {
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

resource "aws_iam_policy" "dragonfly_ml_inferenceclient_policies" {
  name        = "dragonfly-ml-inferenceclient-policies"
  description = "Policies for ml-inferececlient role on kg-node and kg-edge topics"
  policy      = data.aws_iam_policy_document.dragonfly_ml_inferenceclient_policies.json
}

resource "aws_iam_role_policy_attachment" "dragonfly_ml_inferenceclient_policy_attachment" {
  role       = aws_iam_role.dragonfly_ml_inferenceclient.name
  policy_arn = aws_iam_policy.dragonfly_ml_inferenceclient_policies.arn
}
