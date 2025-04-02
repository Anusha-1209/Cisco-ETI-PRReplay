resource "aws_iam_policy" "maqy-dev-role-access" {
  name        = "maqy-dev-role-access"
  path        = "/"
  description = "MAQY SSO IAM role access"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "iam:ListAccountAliases",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:DescribeAddonVersions"
            ],
            "Resource": "*"
        }
    ]
}
EOF

  tags = var.tags
}
