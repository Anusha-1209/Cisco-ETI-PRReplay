
resource "aws_iam_user" "route53-scratch-c-external-DNS" {
  name = "route53-scratch-c-external-DNS"
  path = "/"
  tags = var.tags
}

resource "aws_iam_policy" "route53-scratch-c-external-DNS" {
  name        = "route53-scratch-c-external-DNS"
  path        = "/"
  description = "Scratch-c route53 policy for external-dns"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/Z006572517PCT550AKGRO"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

  tags = var.tags
}


resource "aws_iam_user_policy_attachment" "route53-scratch-c-external-DNS-policy-attachment" {
  user       = aws_iam_user.route53-scratch-c-external-DNS.name
  policy_arn = aws_iam_policy.route53-scratch-c-external-DNS.arn
}

resource "aws_iam_access_key" "route53-scratch-c-external-DNS-access-key" {
  user    = aws_iam_user.route53-scratch-c-external-DNS.name
  status  = "Active"
  pgp_key = ""
}

locals {
  route53-scratch-c-external-DNS = {
    AWS_ACCESS_KEY_ID = element(
      concat(
        aws_iam_access_key.route53-scratch-c-external-DNS-access-key.*.id,
        [""],
      ),
      0
    )
    AWS_SECRET_ACCESS_KEY = element(concat(aws_iam_access_key.route53-scratch-c-external-DNS-access-key.*.secret, [""]), 0)
  }
}

resource "vault_generic_secret" "route53-scratch-c-external-DNS-vault-secret" {
  path      = "secret/dns/scratch/route53-scratch-c-eticloud"
  data_json = jsonencode(local.route53-scratch-c-external-DNS)
}