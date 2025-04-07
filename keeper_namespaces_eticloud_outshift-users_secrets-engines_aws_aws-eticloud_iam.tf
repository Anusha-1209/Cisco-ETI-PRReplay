# Create the IAM user secret engine will use to auth against AWS
resource "aws_iam_user" "vault-secret-engine-dev-sandbox" {
  name = "vault-secret-engine-dev-sandbox"
}

resource "aws_iam_access_key" "vault-secret-engine-dev-sandbox" {
  user = aws_iam_user.vault-secret-engine-dev-sandbox.name
}

resource "aws_iam_user_policy" "vault-secret-engine-dev-sandbox" {
  name = "vault-secret-engine-dev-sandbox"
  user = aws_iam_user.vault-secret-engine-dev-sandbox.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::626007623524:role/dev-sandbox-ecr-access",
      ]
    }
  ]
}
EOF
}

## dev-sandbox-ecr-access role and policy

resource "aws_iam_role" "dev-sandbox-ecr-access" {
  name               = "dev-sandbox-ecr-access"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::626007623524:user/vault-secret-engine-dev-sandbox"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "dev-sandbox-ecr-access"
  }
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
          "ecr:BatchGetRepositoryScanningConfiguration",
          "ecr:TagResource",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetLifecyclePolicy",
          "ecr:DescribeImageScanFindings",
          "ecr:CreateRepository",
          "ecr:PutImageScanningConfiguration",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribePullThroughCacheRules",
          "ecr:GetAuthorizationToken",
          "ecr:PutImage",
          "ecr:UntagResource",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:InitiateLayerUpload",
          "ecr:PutImageTagMutability",
          "ecr:DescribeImageReplicationStatus",
          "ecr:ListTagsForResource",
          "ecr:UploadLayerPart",
          "ecr:CreatePullThroughCacheRule",
          "ecr:ListImages",
          "ecr:PutRegistryPolicy",
          "ecr:GetRegistryScanningConfiguration",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "sts:GetServiceBearerToken",
          "ecr:ReplicateImage",
          "ecr:DescribeRegistry",
          "ecr:BatchImportUpstreamImage",
          "ecr:SetRepositoryPolicy",
          "ecr:GetRepositoryPolicy",
          "ecr:PutReplicationConfiguration"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ecr:us-east-2:626007623524:repository/sandbox/*"
    },
    {
      "Action": [
        "ecr-public:GetAuthorizationToken",
        "sts:GetServiceBearerToken"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dev-sandbox-ecr-access-policy-attach" {
  role       = aws_iam_role.dev-sandbox-ecr-access.name
  policy_arn = aws_iam_policy.dev-sandbox-ecr-access-policy.arn
}
