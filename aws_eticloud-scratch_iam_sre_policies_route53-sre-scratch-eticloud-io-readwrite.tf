resource "aws_iam_policy" "route53-sre-scratch-eticloud-io-readwrite" {
  name = "route53-sre-scratch-eticloud-io-policy"
  path = "/"

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
                "arn:aws:route53:::hostedzone/Z01509942J6PWHDXM6B0U"
            ]
        }
    ]
}
EOF

  tags = var.tags
}
