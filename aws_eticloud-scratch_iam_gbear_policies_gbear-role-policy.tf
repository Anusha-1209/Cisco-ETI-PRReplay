resource "aws_iam_policy" "gbear-role-policy" {
  name = "gbear-role-policy"
  path = "/"
  description = "GreatBear policy attached to gbear SAML role"
  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": [
                    "logs:*",
                    "sts:*",
                    "autoscaling:*",
                    "elasticloadbalancing:*",
                    "cloudwatch:*",
                    "ecr:*",
                    "ec2:*",
                    "eks:*",
                    "iam:*",
                    "s3:*",
                    "ec2-instance-connect:*",
                    "ecr-public:*",
                ],
                "Resource": "*"
            },
          {
              "Sid": "VisualEditor2",
              "Effect": "Allow",
              "Action": [
                  "route53:GetHostedZone",
                  "route53:ChangeResourceRecordSets",
                  "route53:ListResourceRecordSets"
              ],
              "Resource": [
                  "arn:aws:route53:::hostedzone/Z066335133L2EWQS6JDNN",
                  "arn:aws:route53:::hostedzone/Z02597891FFFJGBJLGIGX"
              ]
          },
          {
              "Sid": "VisualEditor3",
              "Effect": "Allow",
              "Action": [
                  "route53:ListHostedZones",
                  "route53:GetHostedZoneCount",
                  "route53:ListHostedZonesByName"
              ],
              "Resource": "*"
          },
          {
              "Effect": "Allow",
              "Action": "route53:GetChange",
              "Resource": "arn:aws:route53:::change/*"
          }
      ]
    }
  )
  tags = var.tags
}
