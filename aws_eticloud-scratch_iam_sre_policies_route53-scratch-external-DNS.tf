resource "aws_iam_policy" "route53-scratch-external-DNS" {
  name        = "route53-scratch-external-DNS"
  path        = "/"
  description = "Scratch route53 policy for external-dns"

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
        "arn:aws:route53:::hostedzone/Z01509942J6PWHDXM6B0U",
        "arn:aws:route53:::hostedzone/Z066335133L2EWQS6JDNN",
        "arn:aws:route53:::hostedzone/Z06824463K6FCU69JG7UW",
        "arn:aws:route53:::hostedzone/Z06205832DXS4MR6N0P9N"
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
