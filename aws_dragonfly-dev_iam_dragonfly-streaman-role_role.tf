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

resource "aws_iam_policy" "policy" {
  name        = "${local.cluster_name}-streaman-kafkaconnect-policy"
  description = "${local.cluster_name} policy for streaman role"
  policy = templatefile(
    "${path.module}/resources/msk-connect-policy.json", {
      kakfa_connect_arangodb_logs_bucket    = data.aws_s3_bucket.mskconnect_logs_bucket.arn
      kakfa_connect_arangodb_execution_role = data.aws_iam_role.mskconnect_arangodb_execution_role.arn
      dragonly_binaries_bucket              = data.aws_s3_bucket.mskconnect_custom_plugin_bucket.arn
  })
}

resource "aws_iam_role" "role" {
  name        = local.role_name
  description = local.role_description

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.policy.arn
  ]
}
