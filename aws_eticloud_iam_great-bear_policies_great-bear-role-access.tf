resource "aws_iam_policy" "great-bear-role-access" {
  name        = "great-bear-role-access"
  path        = "/"
  description = "Great-Bear SSO IAM role access"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "ecr:*",
                "iam:ListAccountAliases",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:DescribeAddonVersions"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "VisualEditor0"
        },
        {
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "GbearS3ConsoleAccess"
        },
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::cisco-eti-gbear-artifacts-dev/*",
                "arn:aws:s3:::cisco-eti-gbear-artifacts-staging/*",
                "arn:aws:s3:::cisco-eti-gbear-artifacts/*"
            ],
            "Sid": "GbearS3ObjectAccess"
        },
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::cisco-eti-gbear-artifacts-dev",
                "arn:aws:s3:::cisco-eti-gbear-artifacts-staging",
                "arn:aws:s3:::cisco-eti-gbear-artifacts"
            ],
            "Sid": "GbearS3BucketAccess"
        }
    ],
    "Version": "2012-10-17"
}
EOF

  tags = var.tags
}
