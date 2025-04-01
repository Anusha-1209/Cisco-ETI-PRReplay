resource "aws_iam_policy" "eti-cisco-com-prod-policy" {
  name        = "eti-cisco-com-prod-policy"
  path        = "/"
  description = "eti.cisco.com website prod policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": "s3:GetObject",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::cisco-eti-banzai-binaries/*",
        "Sid": "binaries"
    },
    {
        "Action": "s3:GetObject",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::cisco-eti-banzai-charts/*",
        "Sid": "charts"
    },
    {
        "Action": [
            "ecr:ListImages",
            "ecr:GetDownloadUrlForLayer",
            "ecr:DescribeImages",
            "ecr:BatchGetImage"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:ecr:us-east-2:033498657557:repository/*",
        "Sid": ""
    },
    {
        "Action": "ecr:GetAuthorizationToken",
        "Effect": "Allow",
        "Resource": "*",
        "Sid": ""
    },
    {
        "Action": "s3:ListBucket",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::cisco-eti-banzai-binaries",
        "Sid": ""
    },
    {
        "Action": "s3:ListBucket",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::cisco-eti-banzai-charts",
        "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}
