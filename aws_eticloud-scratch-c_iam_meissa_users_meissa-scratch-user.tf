resource "aws_iam_user" "meissa-scratch-user" {
  name          = "meissa-scratch-user"
  path          = "/"
  force_destroy = false
  tags = {
    Name = "meissa-scratch-user"
  }
}

resource "aws_iam_access_key" "meissa-scratch-user-key" {
  user    = aws_iam_user.meissa-scratch-user.name
  pgp_key = ""
}

data "aws_iam_policy" "s3-meissa-rw" {
  name = "s3-meissa-rw"
}

resource "aws_iam_user_policy_attachment" "meissa-scratch-user-attachment-1" {
  user       = aws_iam_user.meissa-scratch-user.name
  policy_arn = data.aws_iam_policy.s3-meissa-rw.arn
}

data "null_data_source" "meissa-scratch-user-access-key-secret" {
  inputs = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.meissa-scratch-user-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.meissa-scratch-user-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "meissa-scratch-user-vault-secret" {
  path      = "secret/eticcprod/iam/meissa-scratch-user"
  data_json = jsonencode(data.null_data_source.meissa-scratch-user-access-key-secret.outputs)
}
