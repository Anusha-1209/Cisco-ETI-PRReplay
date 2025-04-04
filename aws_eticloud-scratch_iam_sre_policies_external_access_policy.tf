resource "aws_iam_policy" "external_access_policy" {
  name = "external_access_policy"
  path = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "ecr-public:DescribeRegistries",
            "ecr:ListTagsForResource",
            "s3:ListBucket",
            "ecr:ListImages",
            "ecr:DescribeRepositories",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetLifecyclePolicy",
            "ecr-public:DescribeImageTags",
            "ecr-public:DescribeImages",
            "ecr:GetRegistryPolicy",
            "ecr-public:GetAuthorizationToken",
            "ecr:DescribeImageScanFindings",
            "ecr:GetLifecyclePolicyPreview",
            "ecr-public:GetRepositoryCatalogData",
            "ecr:GetDownloadUrlForLayer",
            "ecr:DescribeRegistry",
            "ecr:GetAuthorizationToken",
            "ecr-public:GetRepositoryPolicy",
            "s3:GetObject",
            "ecr-public:DescribeRepositories",
            "ecr-public:GetRegistryCatalogData",
            "ecr:BatchGetImage",
            "ecr:DescribeImages",
            "iam:ListAccountAliases",
            "ecr-public:ListTagsForResource",
            "ecr-public:BatchCheckLayerAvailability",
            "ecr:GetRepositoryPolicy",
          ]
          Effect   = "Allow"
          Resource = "*"
          Sid      = "VisualEditor0"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = var.tags
}