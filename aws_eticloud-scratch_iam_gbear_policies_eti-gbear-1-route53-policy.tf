resource "aws_iam_policy" "eti-gbear-1-route53-policy" {
  name = "eti-gbear-1-route53-policy"
  path = "/"
  description = "Allows read-write access to gbear.scratch.eticloud.io and gbear-lab.scratch.eticloud.io"
  policy = jsonencode(
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
                    "arn:aws:route53:::hostedzone/Z066335133L2EWQS6JDNN",
                    "arn:aws:route53:::hostedzone/Z02597891FFFJGBJLGIGX"
                ]
            },
            {
                "Sid": "VisualEditor1",
                "Effect": "Allow",
                "Action": "route53:ListHostedZones",
                "Resource": "*"
            }
        ]
    }
  )
  tags = var.tags
}
