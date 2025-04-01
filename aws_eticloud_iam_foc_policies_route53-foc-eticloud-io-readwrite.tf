resource "aws_iam_policy" "route53-foc-eticloud-io-readwrite" {
  name        = "route53-foc-eticloud-io-readwrite"
  path        = "/"
  description = "Route53 Read Write Policy for foc-unicorn.eticloud.io Hosted Zone"

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
                "arn:aws:route53:::hostedzone/Z05645653HAWZF6VVSXG"
            ]
        }
    ]
}
EOF

  tags = var.tags
}
