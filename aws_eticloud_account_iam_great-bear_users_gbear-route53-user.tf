
resource "aws_iam_user" "gbear-route53-user" {
  name          = "gbear-route53-user"
  path          = "/"
  force_destroy = false
  tags = {
    Name = "gbear-route53-user"
  }
}

resource "aws_iam_access_key" "gbear-route53-user-key" {
  user    = aws_iam_user.gbear-route53-user.name
  pgp_key = ""
}

data "aws_iam_policy" "gbear-route53-readwrite" {
  name = "gbear-route53-readwrite"
}

resource "aws_iam_user_policy_attachment" "gbear-route53-user-attachment-1" {
  user       = aws_iam_user.gbear-route53-user.name
  policy_arn = data.aws_iam_policy.gbear-route53-readwrite.arn
}

data "null_data_source" "gbear-route53-user-access-key-secret" {
  inputs = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.gbear-route53-user-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.gbear-route53-user-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "gbear-route53-user-vault-secret" {
  path      = "secret/eticcprod/iam/route53-greatbear-io-eticloud"
  data_json = jsonencode(data.null_data_source.gbear-route53-user-access-key-secret.outputs)
}
