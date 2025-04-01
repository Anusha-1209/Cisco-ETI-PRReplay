
resource "aws_iam_user" "kosha-dev-user" {
  name          = "kosha-dev-user"
  path          = "/"
  force_destroy = false
  tags = {
    Name = "kosha-dev-user"
  }
}

resource "aws_iam_access_key" "kosha-dev-user-key" {
  user    = aws_iam_user.kosha-dev-user.name
  pgp_key = ""
}

data "aws_iam_policy" "kosha-ses-rw" {
  name = "kosha-ses-rw"
}

resource "aws_iam_user_policy_attachment" "kosha-dev-user-attachment-1" {
  user       = aws_iam_user.kosha-dev-user.name
  policy_arn = data.aws_iam_policy.kosha-ses-rw.arn
}

data "null_data_source" "kosha-dev-user-access-key-secret" {
  inputs = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.kosha-dev-user-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.kosha-dev-user-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "kosha-dev-user-vault-secret" {
  path      = "secret/eticcprod/iam/kosha-dev-user"
  data_json = jsonencode(data.null_data_source.kosha-dev-user-access-key-secret.outputs)
}
