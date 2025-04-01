resource "aws_iam_user" "s3-elastic-logging-prod-user" {
  name          = "s3-elastic-logging-prod-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
}

resource "aws_iam_access_key" "s3-elastic-logging-prod-user" {
  user    = aws_iam_user.s3-elastic-logging-prod-user.name
  status  = "Inactive"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "s3-elastic-logging-prod-user-policy-attachment" {
  user       = aws_iam_user.s3-elastic-logging-prod-user.name
  policy_arn = "arn:aws:iam::626007623524:policy/sre-s3-elastic-logging-prod-ro"
}

locals {
  s3-elastic-logging-prod-user = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.s3-elastic-logging-prod-user.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.s3-elastic-logging-prod-user.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "s3-elastic-logging-prod-user-vault-secret" {
  path      = "secret/eticcprod/iam/s3-elastic-logging-prod-user"
  data_json = jsonencode(local.s3-elastic-logging-prod-user)
}