data "aws_caller_identity" "current" {
  provider = aws.kendra
}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

#region Create the IAM user secret engine will use to auth against AWS
resource "aws_iam_user" "vault-secret-engine-user-kendra" {
  provider = aws.kendra
  name     = "vault-secret-engine-user-kendra"
}

resource "aws_iam_access_key" "vault-secret-engine-user-kendra" {
  provider = aws.kendra
  user     = aws_iam_user.vault-secret-engine-user-kendra.name
}

resource "aws_iam_user_policy" "vault-secret-engine-user-kendra" {
  provider = aws.kendra
  name     = "vault-secret-engine-user-kendra"
  user     = aws_iam_user.vault-secret-engine-user-kendra.name
  policy   = <<EOF
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

# Additional IAM role for the user
resource "aws_iam_role" "jenkins" {
  provider           = aws.kendra
  name               = "jenkins"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
        "AWS" : "${aws_iam_user.vault-secret-engine-user-kendra.arn}"
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
  provider    = aws.kendra
  name        = "jenkins-policy"
  description = "jenkins policy for jenkins-role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
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

# Attach the jenkins policy to the jenkins-role
resource "aws_iam_role_policy_attachment" "jenkins-policy-attach" {
  provider   = aws.kendra
  role       = aws_iam_role.jenkins.name
  policy_arn = aws_iam_policy.jenkins-policy.arn
}









