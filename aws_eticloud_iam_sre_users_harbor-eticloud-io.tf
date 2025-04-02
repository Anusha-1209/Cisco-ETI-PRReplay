resource "aws_iam_policy" "harbor-eticloud-io" {
  name        = "harbor-eticloud-io"
  path        = "/"
  description = "Harbor S3 Policy for harbor.eticloud.io"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucketMultipartUploads",
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::cisco-eti-data-harbor-eticloud-io"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:::cisco-eti-data-harbor-eticloud-io/*"
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_user" "harbor-eticloud-io" {
  name          = "harbor-eticloud-io"
  path          = "/"
  force_destroy = false
  tags          = var.tags
  depends_on = [
    aws_iam_policy.harbor-eticloud-io
  ]
}

resource "aws_iam_access_key" "harbor-eticloud-io-access-key" {
  user    = aws_iam_user.harbor-eticloud-io.name
  status  = "Inactive"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "harbor-eticloud-io-attachment" {
  user       = aws_iam_user.harbor-eticloud-io.name
  policy_arn = aws_iam_policy.harbor-eticloud-io.arn
  depends_on = [
    aws_iam_user.harbor-eticloud-io
  ]
}

locals {
  harbor-eticloud-io = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.harbor-eticloud-io-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.harbor-eticloud-io-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "harbor-eticloud-io-vault-secret" {
  path      = "secret/eticcprod/iam/harbor-eticloud-io"
  data_json = jsonencode(local.harbor-eticloud-io)
}