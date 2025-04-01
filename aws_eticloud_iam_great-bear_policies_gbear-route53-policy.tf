resource "aws_iam_policy" "gbear-route53-readwrite" {
  name        = "gbear-route53-readwrite"
  path        = "/"
  description = "Route53 Read Write Policy for greatbear.io Hosted Zone"

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
                "arn:aws:route53:::hostedzone/Z034982022T1DOPUHJR2W"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Action": [
                "route53:ListHostedZones"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

  tags = merge(var.tags, { "Environment" : "Prod" })
}
