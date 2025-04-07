resource "aws_iam_user" "eti-cisco-com-prod-user" {
  name          = "eti-cisco-com-prod-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
}

resource "aws_iam_access_key" "eti-cisco-com-prod-user-access-key" {
  user    = aws_iam_user.eti-cisco-com-prod-user.name
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "eti-cisco-com-prod-user-policy-attachment" {
  user       = aws_iam_user.eti-cisco-com-prod-user.name
  policy_arn = "arn:aws:iam::626007623524:policy/eti-cisco-com-prod-policy"
}
locals {
  eti-com-com-prod-user = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.eti-cisco-com-prod-user-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.eti-cisco-com-prod-user-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "eti-cisco-com-prod-user-vault-secret" {
  path      = "secret/eticcprod/iam/eti-cisco-com-prod-user"
  data_json = jsonencode(local.eti-com-com-prod-user)
}