# GHA IAM Role trust relationships
data "aws_iam_policy_document" "github_assume_role_policy" {
  statement {
    effect     = "Allow"
    principals {
        type        = "Federated"
        identifiers = ["arn:aws:iam::626007623524:oidc-provider/token.actions.githubusercontent.com"]
    }
    actions   = ["sts:AssumeRoleWithWebIdentity"]
    condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
    }
    condition {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub" 
        values   = ["repo:cisco-eti/*:*"]
    }
  }
}

# GHA IAM policy
data "aws_iam_policy_document" "gha_policy" {
  # ECR private polciy
  statement {
    sid      = "AllowPrivateECR"
    effect   = "Allow"
    actions  = [
        "ecr:*"
    ]
    resources = ["*"]
  }
  # ECR public policy
  statement {
    sid     = "GetAuthorizationToken"
    effect  = "Allow"
    actions = [
        "ecr-public:GetAuthorizationToken",
        "sts:GetServiceBearerToken"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowPulicECR"
    effect = "Allow"
    actions = [
        "ecr-public:BatchCheckLayerAvailability",
        "ecr-public:CompleteLayerUpload",
        "ecr-public:InitiateLayerUpload",
        "ecr-public:PutImage",
        "ecr-public:UploadLayerPart"
    ]
    resources = ["arn:aws:ecr-public::626007623524:repository/*"]
  }

# CodeArtifact policy
  statement {
    sid    = "AllowCodeArtifact"
    effect = "Allow"
    actions = [
        "codeartifact:DescribeDomain",
        "codeartifact:DescribePackage",
        "codeartifact:DescribePackageVersion",
        "codeartifact:DescribeRepository",
        "codeartifact:GetAuthorizationToken",
        "codeartifact:GetDomainPermissionsPolicy",
        "codeartifact:GetPackageVersionAsset",
        "codeartifact:GetPackageVersionReadme",
        "codeartifact:GetRepositoryEndpoint",
        "codeartifact:GetRepositoryPermissionsPolicy",
        "codeartifact:ListDomains",
        "codeartifact:ListPackageVersionAssets",
        "codeartifact:ListPackageVersionDependencies",
        "codeartifact:ListPackageVersions",
        "codeartifact:ListPackages",
        "codeartifact:ListRepositories",
        "codeartifact:ListRepositoriesInDomain",
        "codeartifact:ListTagsForResource",
        "codeartifact:PublishPackageVersion",
        "codeartifact:ReadFromRepository",
        "codeartifact:TagResource",
        "codeartifact:UntagResource",
        "codeartifact:UpdatePackageVersionsStatus"
    ]
    resources = ["*"]
  }
}

# GHA IAM Role
resource "aws_iam_role" "gha_role" {
  name        = "gh-actions-role"
  description = "IAM Role for GH Actions workflows"
  tags        = var.tags
  
  assume_role_policy = data.aws_iam_policy_document.github_assume_role_policy.json
  inline_policy {
    name   = "gha-policy"
    policy = data.aws_iam_policy_document.gha_policy.json
  }
  managed_policy_arns = []
}