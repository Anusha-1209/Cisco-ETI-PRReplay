# GHA IAM Role trust relationships
data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "github_assume_role_policy" {
  statement {
    effect     = "Allow"
    principals {
        type        = "Federated"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
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
  statement {
    actions = [
      "lambda:CreateFunction",
      "iam:GetRole",
      "lambda:TagResource",
      "lambda:InvokeFunction",
      "lambda:GetEventSourceMapping",
      "lambda:ListVersionsByFunction",
      "logs:DeleteLogGroup",
      "lambda:GetFunction",
      "lambda:UpdateFunctionConfiguration",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "lambda:UpdateFunctionCode",
      "logs:CreateLogStream",
      "iam:PassRole",
      "iam:DetachRolePolicy",
      "lambda:ListTags",
      "iam:DeleteRolePolicy",
      "lambda:DeleteFunction",
      "lambda:PublishVersion"
    ]

    resources = [
      "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:dspm*",
      "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:event-source-mapping:dspm*",
      "arn:aws:logs:*:*:*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/gh-actions-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/dspm-*"
    ]
    effect    = "Allow"
  }

  statement {
    actions   = [
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResource",
      "lambda:CreateEventSourceMapping",
      "cloudformation:CreateChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:ValidateTemplate",
      "cloudformation:DescribeStacks",
      "cloudformation:ListStackResources"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "s3:*"
    ]

    resources = ["arn:aws:s3:::dspm-*"]
    effect    = "Allow"
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