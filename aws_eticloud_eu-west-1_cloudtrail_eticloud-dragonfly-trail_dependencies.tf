data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/prod/aws"
  provider = vault.eticcprod
}

data "aws_iam_policy_document" "dragonfly_falco_data_collector" {
  statement {
    sid = "1"

    effect    = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket"
    ]
    resources = [
      module.cloudtrail[0].s3_bucket_arn,
      "${module.cloudtrail[0].s3_bucket_arn}/*",
    ]
  }

  statement {
    sid = "2"

    effect    = "Allow"
    actions = [
      "sns:Subscribe"
    ]
    resources = [
      module.cloudtrail[0].sns_topic_arn
    ]
  }
}

data "aws_iam_policy_document" "dragonfly_falco_data_collector_assume_role" {
  statement {
    sid = "1"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::626007623524:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/1C1C7BCDE7C743BDE3D27F1D009FFD56"]
    }

    effect    = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.eu-west-1.amazonaws.com/id/1C1C7BCDE7C743BDE3D27F1D009FFD56:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.eu-west-1.amazonaws.com/id/1C1C7BCDE7C743BDE3D27F1D009FFD56:sub"

      values = [
        "system:serviceaccount:dragonfly-data-collector:dragonfly-data-collector-falco"
      ]
    }
  }
}
