data "aws_iam_policy_document" "cloudformation_execution_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "cloudformation.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudformation_execution_role_policy" {
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
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupEgress",
    ]

    resources = ["*"]

    effect = "Allow"
  }

  statement {
    actions = [
      "ec2:DeleteSecurityGroup",
    ]

    resources = ["*"]

    condition {
        test     = "StringEquals"
        variable = "ec2:ResourceTag/ApplicationName"
        values   = [
            local.lambda_application,
        ]
    }

    effect = "Allow"
  }

  # Deploy Lambda functions
  statement {
    actions = [
      "lambda:Get*",
      "lambda:List*",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:UpdateFunctionConfiguration",
      "lambda:UpdateFunctionCode",
      "lambda:PublishVersion",
      "lambda:CreateAlias",
      "lambda:DeleteAlias",
      "lambda:UpdateAlias",
      "lambda:AddPermission",
      "lambda:RemovePermission",
      "lambda:InvokeFunction",
      "lambda:TagResource",
    ]

    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_application}-*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "lambda:GetAccountSettings",
      "lambda:GetEventSourceMapping",
      "lambda:ListEventSourceMappings",
    ]

    resources = [
      "*"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "lambda:DeleteEventSourceMapping",
      "lambda:UpdateEventSourceMapping",
      "lambda:CreateEventSourceMapping"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringLike"
      variable = "lambda:FunctionArn"
      values = [
        "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_application}-*",
      ]
    }
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:Get*",
      "logs:Describe*",
      "logs:List*",
      "logs:DeleteLogGroup",
      "logs:PutResourcePolicy",
      "logs:DeleteResourcePolicy",
      "logs:PutRetentionPolicy",
      "logs:DeleteRetentionPolicy",
      "logs:TagLogGroup",
      "logs:UntagLogGroup",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_application}-*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "logs:Describe*",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
    ]

    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "iam:Get*",
      "iam:List*",
      "iam:PassRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.lambda_application}-*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:CreateTableReplica",
      "dynamodb:CreateGlobalTable",
      "dynamodb:DeleteTable",
      "dynamodb:DeleteGlobalTable",
      "dynamodb:DeleteTableReplica",
      "dynamodb:Describe*",
      "dynamodb:List*",
      "dynamodb:Get*",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:UpdateContinuousBackups",
      "dynamodb:UpdateGlobalTable",
      "dynamodb:UpdateGlobalTableSettings",
      "dynamodb:UpdateTable",
      "dynamodb:UpdateTableReplicaAutoScaling",
      "dynamodb:UpdateTimeToLive",
    ]

    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${local.lambda_application}-*",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:global-table/${local.lambda_application}-*",
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
      "ecr:SetRepositoryPolicy",
      "ecr:GetRepositoryPolicy",
    ]

    resources = [
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role" "cloudformation_execution_role" {
  name        = local.role_name
  description = "IAM Role for cloud formation service"

  assume_role_policy = data.aws_iam_policy_document.cloudformation_execution_assume_role_policy.json
  inline_policy {
    name   = "cloud-formation-policy"
    policy = data.aws_iam_policy_document.cloudformation_execution_role_policy.json
  }
  managed_policy_arns = []
}
