resource "aws_iam_user" "s3-chart-museum-user" {
  name          = "s3-chart-museum-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
}

resource "aws_iam_access_key" "s3-chart-museum-user-access-key" {
  user    = aws_iam_user.s3-chart-museum-user.name
  status  = "Inactive"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "s3-chart-museum-user-policy-attachment" {
  user       = aws_iam_user.s3-chart-museum-user.name
  policy_arn = "arn:aws:iam::626007623524:policy/s3-eti-helm-charts-readwrite"
}

locals {
  s3-chart-museum-user = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.s3-chart-museum-user-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.s3-chart-museum-user-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "s3-chart-museum-user-vault-secret" {
  path      = "secret/eticcprod/iam/s3-chart-museum-user"
  data_json = jsonencode(local.s3-chart-museum-user)
}