data "aws_caller_identity" "current" {
  provider = aws.vowel-genai-dev
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Create the IAM user secret engine will use to auth against AWS

resource "aws_iam_user" "vault-secret-engine-user-promptintel-dev" {
  provider  = aws.vowel-genai-dev
  name      = "vault-secret-engine-user-promptintel-dev"
}

resource "aws_iam_access_key" "vault-secret-engine-user-promptintel-dev" {
  provider  = aws.vowel-genai-dev
  user      = aws_iam_user.vault-secret-engine-user-promptintel-dev.name
}

resource "aws_iam_user_policy" "vault-secret-engine-user-promptintel-dev" {
  provider  = aws.vowel-genai-dev
  name      = "vault-secret-engine-user-promptintel-dev"
  user      = aws_iam_user.vault-secret-engine-user-promptintel-dev.name

  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::${local.account_id}:role/jenkins-promptintel"
      ]
    }
  ]
}
EOF
}


## jenkins role and policy

data "aws_iam_role" "jenkins-promptintel" {
  provider           = aws.vowel-genai-dev
  name               = "jenkins"
  # assume_role_policy = jsonencode({
  #   "Version" : "2012-10-17",
  #   "Statement" : [
  #     {
  #       "Effect" : "Allow",
  #       "Principal" : {
  #         "AWS" : "arn:aws:iam::${local.account_id}:user/vault-secret-engine-user-promptintel-dev"
  #       },
  #       "Action" : "sts:AssumeRole"
  #     }
  #   ]
  # })
}

resource "aws_iam_policy" "jenkins-promptintel-policy" {
  provider    = aws.vowel-genai-dev
  name        = "jenkins-promptintel-policy"
  description = "SageMaker access for Jenkins"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "s3:ListBucket",
              "sagemaker:*",
              "application-autoscaling:*",
              "iam:CreateServiceLinkedRole",
              "iam:PassRole",
              "s3:CreateBucket",
              "cloudwatch:PutMetricAlarm",
              "cloudwatch:DeleteAlarms",
              "cloudwatch:DescribeAlarms"
          ],
          "Effect": "Allow",
          "Resource": [
              "*",
              "*",
              "*",
              "*",
              "*",
              "*",
              "*",
              "*",
              "*"
          ]
      },
      {
          "Action": [
              "s3:GetObject",
              "s3:PutObject",
              "s3:DeleteObject"
          ],
          "Effect": "Allow",
          "Resource": [
              "*"
          ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "kendra:Query",
          "kendra:CreateIndex",
          "kendra:DeleteIndex",
          "kendra:DescribeIndex",
          "kendra:ListIndices",
          "kendra:CreateDataSource",
          "kendra:DescribeDataSource",
          "kendra:StartDataSourceSyncJob",
          "kendra:ListDataSourceSyncJobs"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:CreatePolicy",
          "iam:GetPolicy",
          "iam:DeletePolicy",
          "iam:GetRole",
          "iam:DeleteRole",
          "iam:PassRole",
          "iam:DeleteRolePolicy",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:ListAttachedRolePolicies",
          "iam:ListAttachedUserPolicies"
        ],
        "Resource": "*"
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jenkins-promptintel-policy-attach" {
  provider    = aws.vowel-genai-dev
  role        = data.aws_iam_role.jenkins-promptintel.name
  policy_arn  = aws_iam_policy.jenkins-promptintel-policy.arn
}

data "aws_iam_policy" "ci-ecr-cloudwatch-policy" {
  provider    = aws.vowel-genai-dev
  name        = "ci-ecr-cloudwatch-policy"
}

resource "aws_iam_role_policy_attachment" "ci-ecr-cloudwatch-policy-attach" {
  provider    = aws.vowel-genai-dev
  role        = data.aws_iam_role.jenkins-promptintel.name
  policy_arn  = data.aws_iam_policy.ci-ecr-cloudwatch-policy.arn
}

