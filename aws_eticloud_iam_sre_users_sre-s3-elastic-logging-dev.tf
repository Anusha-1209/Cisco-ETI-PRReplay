resource "aws_iam_user" "s3-elastic-logging-dev-user" {
  name          = "s3-elastic-logging-dev-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
}

resource "aws_iam_access_key" "s3-elastic-logging-dev-user" {
  user    = aws_iam_user.s3-elastic-logging-dev-user.name
  status  = "Inactive"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "s3-elastic-logging-dev-user-policy-attachment" {
  user       = aws_iam_user.s3-elastic-logging-dev-user.name
  policy_arn = "arn:aws:iam::626007623524:policy/sre-s3-elastic-logging-dev-ro"
}

locals {
  s3-elastic-logging-dev-user = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.s3-elastic-logging-dev-user.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.s3-elastic-logging-dev-user.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "s3-elastic-logging-dev-user-vault-secret" {
  path      = "secret/eticcprod/iam/s3-elastic-logging-dev-user"
  data_json = jsonencode(local.s3-elastic-logging-dev-user)
}