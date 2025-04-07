resource "aws_iam_policy" "banzai-ecr" {
  name        = "banzai-ecr"
  path        = "/"
  description = "Allow fetching images from the Banzai ECR repositories"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPullingImages",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage"
            ],
            "Resource": "arn:aws:ecr:us-east-2:033498657557:repository/*"
        },
        {
            "Sid": "AllowAuthorization",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF

  tags = var.tags
}
