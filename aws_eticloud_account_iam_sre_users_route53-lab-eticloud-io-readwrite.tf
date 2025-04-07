resource "aws_iam_policy" "route53-lab-eticloud-io-readwrite" {
  name        = "route53-lab-eticloud-io-readwrite"
  path        = "/"
  description = "Route53 Read Write Policy for lab.eticloud.io Hosted Zone"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "vim0",
            "Effect": "Allow",
            "Action": [
                "route53:GetHostedZone",
                "route53:ListHostedZones",
                "route53:ListHostedZonesByName",
                "route53:GetHostedZoneCount",
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
              "arn:aws:route53:::hostedzone/Z00312495LKNACA8AYZL",
              "arn:aws:route53:::hostedzone/Z0145219CLGSWP6ZJN3B"
            ]
        },
        {
            "Sid": "vim1",
            "Effect": "Allow",
            "Action": [
 		"route53:ListHostedZones",
                "route53:GetChange"],
            "Resource": "*"
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_user" "route53-lab-acme-user" {
  name          = "route53-lab-acme-user"
  path          = "/"
  force_destroy = false
  tags          = var.tags
  depends_on = [
    aws_iam_policy.route53-lab-eticloud-io-readwrite
  ]
}

resource "aws_iam_access_key" "route53-lab-acme-user-access-key" {
  user    = aws_iam_user.route53-lab-acme-user.name
  status  = "Inactive"
  pgp_key = ""
}

resource "aws_iam_user_policy_attachment" "route53-lab-policy-attachment" {
  user       = aws_iam_user.route53-lab-acme-user.name
  policy_arn = aws_iam_policy.route53-lab-eticloud-io-readwrite.arn
  depends_on = [
    aws_iam_user.route53-lab-acme-user
  ]
}

locals {
  route53-lab-acme-user = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.route53-lab-acme-user-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.route53-lab-acme-user-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "route53-lab-acme-user-vault-secret" {
  path      = "secret/eticcprod/iam/route53-lab-acme-user"
  data_json = jsonencode(local.route53-lab-acme-user)
}
