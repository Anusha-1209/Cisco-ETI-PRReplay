provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/vowel-genai-dev/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
}

resource "aws_iam_user" "motific-dev-bedrock-user-user" {
  name          = "motific-dev-bedrock-user"
  path          = "/"
  force_destroy = false
  tags = {
    Name = "motific-dev-bedrock-user"
  }
}

resource "aws_iam_access_key" "motific-dev-bedrock-user-key" {
  user    = aws_iam_user.motific-dev-bedrock-user-user.name
  pgp_key = ""
}

resource "aws_iam_user_policy" "motific-dev-bedrock-user-policy" {
  name      = "motific-dev-bedrock-user"
  user      = aws_iam_user.motific-dev-bedrock-user-user.name

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
        aws_iam_access_key.motific-dev-bedrock-user-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.motific-dev-bedrock-user-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "motific-dev-bedrock-user-vault-secret" {
  provider  = vault.eticloud
  path      = "secret/eticcprod/iam/motific-dev-bedrock-user"
  data_json = jsonencode(local.iam_creds)
}