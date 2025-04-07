# Create the IAM user secret engine will use to auth against AWS
resource "aws_iam_user" "vault-secret-engine-dev-sandbox" {
  name = "vault-secret-engine-dev-sandbox"
}

resource "aws_iam_user_policy" "vault-secret-engine-dev-sandbox-policy" {
  name   = "vault-secret-engine-dev-sandbox-policy"
  user   = aws_iam_user.vault-secret-engine-dev-sandbox.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "iam:CreateUser",
          "iam:PutUserPolicy",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:DeleteUser"

      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "vault-secret-engine-dev-sandbox" {
  user = aws_iam_user.vault-secret-engine-dev-sandbox.name
}

resource "aws_iam_policy" "dev-sandbox-ecr-access-policy" {
  name        = "dev-sandbox-ecr-access-policy"
  description = "Write access to ECR for Dev Sandbox storage"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:BatchGetRepositoryScanningConfiguration",
          "ecr:TagResource",
          "ecr:GetLifecyclePolicy",
          "ecr:DescribeImageScanFindings",
          "ecr:CreateRepository",
          "ecr:PutImageScanningConfiguration",
          "ecr:DescribePullThroughCacheRules",
          "ecr:UntagResource",
          "ecr:PutImageTagMutability",
          "ecr:DescribeImageReplicationStatus",
          "ecr:ListTagsForResource",
          "ecr:CreatePullThroughCacheRule",
          "ecr:PutRegistryPolicy",
          "ecr:GetRegistryScanningConfiguration",
          "sts:GetServiceBearerToken",
          "ecr:ReplicateImage",
          "ecr:DescribeRegistry",
          "ecr:BatchImportUpstreamImage",
          "ecr:SetRepositoryPolicy",
          "ecr:PutReplicationConfiguration"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ecr:us-east-2:626007623524:repository/sandbox/*"
    },
    {
      "Action": [
        "sts:GetCallerIdentity",
        "ecr:GetAuthorizationToken"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}