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
        "${aws_iam_role.default-role.arn}"
      ]
    }
  ]
}
EOF

}
#endregion


#region default role and policy attachments
resource "aws_iam_role" "default-role" {
  provider           = aws.kendra
  name               = "default"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.vault-secret-engine-user-kendra.arn}"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${local.account_id}:root"
        },
        "Action": "sts:AssumeRole",
        "Condition": {}
    }
    ]
  })

  tags = {
    Name = "default"
  }
}
#endregion


# Additional IAM role for the user
resource "aws_iam_role" "custom-role" {
  provider           = aws.kendra
  name               = "custom-role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
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
    Name = "custom-role"
  }
}


resource "aws_iam_policy" "custom-policy" {
  provider    = aws.kendra
  name        = "custom-policy"
  description = "Custom policy for custom-role"
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

# Attach the custom policy to the custom-role
resource "aws_iam_role_policy_attachment" "custom-policy-attach" {
  provider   = aws.kendra
  role       = aws_iam_role.custom-role.name
  policy_arn = aws_iam_policy.custom-policy.arn
}









