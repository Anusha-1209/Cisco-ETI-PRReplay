resource "aws_iam_role" "dragonfly_thrill_msk_writer" {
  name = "${local.cluster_name}-thrill-msk-writer-role"

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
            "${local.oidc_id}:sub" : "system:serviceaccount:${local.dragonfly_argo_service_account}"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

data "aws_iam_policy_document" "dragonfly_thrill_msk_writer_policies" {
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
      "kafka-cluster:WriteData",
    ]

    resources = [
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/threat",
      "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${data.aws_msk_cluster.dragonfly_msk_1.cluster_name}/${data.aws_msk_cluster.dragonfly_msk_1.cluster_uuid}/attack",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "dragonfly_thrill_msk_writer_policies" {
  name        = "${local.cluster_name}-thrill-msk-writer-policies"
  description = "Policies for thrill MSK writer role on threat and attack topics"
  policy      = data.aws_iam_policy_document.dragonfly_thrill_msk_writer_policies.json
}

resource "aws_iam_role_policy_attachment" "dragonfly_thrill_msk_writer_policy_attachment" {
  role       = aws_iam_role.dragonfly_thrill_msk_writer.name
  policy_arn = aws_iam_policy.dragonfly_thrill_msk_writer_policies.arn
}
