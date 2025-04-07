
resource "aws_iam_user" "eti-identity-dev-user" {
  name          = "eti-identity-dev-user"
  path          = "/"
  force_destroy = false
  tags = {
    Name = "eti-identity-dev-user"
  }
}

resource "aws_iam_access_key" "eti-identity-dev-user-key" {
  user    = aws_iam_user.eti-identity-dev-user.name
  pgp_key = ""
}

data "aws_iam_policy" "eti-identity-ses-rw" {
  name = "eti-identity-ses-rw"
}

resource "aws_iam_user_policy_attachment" "eti-identity-dev-user-attachment-1" {
  user       = aws_iam_user.eti-identity-dev-user.name
  policy_arn = data.aws_iam_policy.eti-identity-ses-rw.arn
}

data "null_data_source" "eti-identity-dev-user-access-key-secret" {
  inputs = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.eti-identity-dev-user-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.eti-identity-dev-user-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "eti-identity-dev-user-vault-secret" {
  path      = "secret/eticcprod/iam/eti-identity-dev-user"
  data_json = jsonencode(data.null_data_source.eti-identity-dev-user-access-key-secret.outputs)
}
