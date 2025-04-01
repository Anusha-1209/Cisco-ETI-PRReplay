data "aws_partition" "current" {
  provider    = aws.motific-prod
}

data "aws_caller_identity" "current" {
  provider    = aws.motific-prod
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Create the IAM user secret engine will use to auth against AWS

resource "aws_iam_user" "vault-secret-engine-user-motific-prod" {
  provider  = aws.motific-prod
  name      = "vault-secret-engine-user-motific-prod"
}

resource "aws_iam_access_key" "vault-secret-engine-user-motific-prod" {
  provider  = aws.motific-prod
  user      = aws_iam_user.vault-secret-engine-user-motific-prod.name
}

resource "aws_iam_user_policy" "vault-secret-engine-user-motific-prod" {
  provider  = aws.motific-prod
  name      = "vault-secret-engine-user-motific-prod"
  user      = aws_iam_user.vault-secret-engine-user-motific-prod.name

  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::${local.account_id}:role/jenkins"
      ]
    }
  ]
}
EOF
}


## jenkins role and policy

resource "aws_iam_role" "jenkins" {
  provider           = aws.motific-prod
  name               = "jenkins"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.account_id}:user/vault-secret-engine-user-motific-prod"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "jenkins"
  }
}

resource "aws_iam_policy" "jenkins-policy" {
  provider    = aws.motific-prod
  name        = "jenkins-policy"
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
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jenkins-policy-attach" {
  provider    = aws.motific-prod
  role        = aws_iam_role.jenkins.name
  policy_arn  = aws_iam_policy.jenkins-policy.arn
}

