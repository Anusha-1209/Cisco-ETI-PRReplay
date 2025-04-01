resource "aws_iam_policy" "route53-eticloud-scratch-c-rw" {
  name        = "route53-eticloud-scratch-c-rw"
  path        = "/"
  description = "Route53 Read Write Policy for scratch-c.eticloud.io Hosted Zone"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "route53:ListTagsForResources",
                "route53:GetChange",
                "route53:GetHostedZone",
                "route53:ChangeResourceRecordSets",
                "route53:ChangeTagsForResource",
                "route53:ListResourceRecordSets",
                "route53:ListTagsForResource"
            ],
            "Resource": [
                "arn:aws:route53:::change/*",
                "arn:aws:route53:::hostedzone/Z006572517PCT550AKGRO"
            ]
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_user" "route53-scratch-c-readwrite" {
  name          = "route53-scratch-c-readwrite"
  path          = "/"
  force_destroy = false
  tags          = var.tags
  depends_on = [
    aws_iam_policy.route53-eticloud-scratch-c-rw
  ]
}

resource "aws_iam_access_key" "route53-scratch-c-readwrite-access-key" {
  user    = aws_iam_user.route53-scratch-c-readwrite.name
  status  = "Active"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "route53-scratch-c-readwrite-attachment" {
  user       = aws_iam_user.route53-scratch-c-readwrite.name
  policy_arn = aws_iam_policy.route53-eticloud-scratch-c-rw.arn
  depends_on = [
    aws_iam_user.route53-scratch-c-readwrite
  ]
}

locals {
  route53-scratch-c-readwrite = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.route53-scratch-c-readwrite-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.route53-scratch-c-readwrite-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "route53-scratch-c-readwrite-vault-secret" {
  path      = "secret/eticcprod/iam/route53-scratch-c-eticloud"
  data_json = jsonencode(local.route53-scratch-c-readwrite)
}