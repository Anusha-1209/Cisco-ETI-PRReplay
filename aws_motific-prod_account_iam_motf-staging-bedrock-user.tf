resource "aws_iam_user" "motf_prod_bedrock_user" {
  name          = "motf-prod-bedrock-user"
  path          = "/"
  force_destroy = false
  tags = {
    Name = "motf-prod-bedrock-user"
  }
}

resource "aws_iam_access_key" "motf_prod_bedrock_user_key" {
  user    = aws_iam_user.motf_prod_bedrock_user.name
  pgp_key = ""
}

resource "aws_iam_user_policy" "motf-prod-bedrock-user-policy" {
  name = "motf-prod-bedrock-user"
  user = aws_iam_user.motf_prod_bedrock_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "bedrock:*",
          "Effect": "Allow",
          "Resource": "*"
      }
  ]
}
EOF
}

locals {
  iam_creds = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.motf_prod_bedrock_user_key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.motf_prod_bedrock_user_key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "motf_prod_bedrock_user_vault_secret" {
  provider  = vault.eticloud
  path      = "secret/eticcprod/iam/motf-prod-bedrock-user"
  data_json = jsonencode(local.iam_creds)
}