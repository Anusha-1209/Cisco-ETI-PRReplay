data "aws_iam_policy_document" "github_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
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

  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::474213319131:role/admin",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

# GHA IAM policy
data "aws_iam_policy_document" "gha_policy" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::dragonfly-*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "iam:PassRole"
    ]

    resources = [
      data.aws_iam_role.cloudformation_execution_role.arn,
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "cloudformation:CreateChangeSet"
    ]

    resources = [
      "arn:aws:cloudformation:*:aws:transform/Serverless-2016-10-31"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "cloudformation:ValidateTemplate"
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "cloudformation:CreateChangeSet",
      "cloudformation:CreateStack",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeChangeSet",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStackResources",
      "cloudformation:DescribeStacks",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:ListStackResources",
      "cloudformation:SetStackPolicy",
      "cloudformation:UpdateStack",
      "cloudformation:UpdateTerminationProtection",
      "cloudformation:GetTemplate",
      "cloudformation:GetTemplateSummary",
    ]

    resources = [
      "arn:aws:cloudformation:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stack/${local.lambda_application}-*/*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "lambda:Get*",
      "lambda:List*",
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:SetRepositoryPolicy",
      "ecr:UploadLayerPart",
      "ecr:TagResource",
      "ecr:BatchDeleteImage",
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DeleteRepositoryPolicy",
    ]

    resources = [
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*",
    ]

    effect = "Allow"
  }
}

# GHA IAM Role
resource "aws_iam_role" "gha_role" {
  name        = "gh-actions-role"
  description = "IAM Role for GH Actions workflows"

  assume_role_policy = data.aws_iam_policy_document.github_assume_role_policy.json
  inline_policy {
    name   = "gha-policy"
    policy = data.aws_iam_policy_document.gha_policy.json
  }
  managed_policy_arns = []
}
