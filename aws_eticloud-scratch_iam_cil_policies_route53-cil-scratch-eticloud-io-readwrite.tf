resource "aws_iam_policy" "route53-cil-scratch-eticloud-io-readwrite" {
  name        = "route53-cil-scratch-eticloud-io-readwrite"
  path        = "/"
  description = "Route53 Read Write Policy for cil.scratch.eticloud.io Hosted Zone"

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
                "arn:aws:route53:::hostedzone/Z04554961B8AO17ZZYCCW"
            ]
        }
    ]
}
EOF

  tags = var.tags
}
