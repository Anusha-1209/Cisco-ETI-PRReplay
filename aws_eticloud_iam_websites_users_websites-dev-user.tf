
provider "vault" {
  alias     = "eticloud"
  namespace = "eticloud"
}

resource "aws_iam_user" "websites-s3-access-user" {
  name          = "websites-s3-access"
  path          = "/"
  force_destroy = false
  tags = {
    Name = "websites-s3-access"
  }
}

resource "aws_iam_access_key" "websites-s3-access-key" {
  user    = aws_iam_user.websites-s3-access-user.name
  pgp_key = ""
}

resource "aws_iam_user_policy" "websites-s3-access-policy" {
  name      = "outshift-websites-s3-access"
  user      = aws_iam_user.websites-s3-access-user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:DeleteObject",
              "s3:PutObjectAcl"
          ],
          "Effect": "Allow",
          "Resource": [
              "arn:aws:s3:::outshift-headless-cms-s3/*",
              "arn:aws:s3:::research-strapi-s3/*"
          ]
      }
  ]
}
EOF
}

locals {
  iam_creds = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.websites-s3-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.websites-s3-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "websites-s3-access-vault-secret" {
  provider  = vault.eticloud
  path      = "secret/eticcprod/iam/websites-dev-user"
  data_json = jsonencode(local.iam_creds)
}
