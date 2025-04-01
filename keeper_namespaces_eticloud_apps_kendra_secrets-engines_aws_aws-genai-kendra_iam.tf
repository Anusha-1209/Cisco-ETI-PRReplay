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
        "${aws_iam_role.ci-default-role.arn}"
      ]
    }
  ]
}
EOF
  
}
#endregion


#region ci-default role and policy attachments
resource "aws_iam_role" "ci-default-role" {
  provider           = aws.kendra
  name               = "ci-default"
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
    Name = "ci-default"
  }
}
#endregion


# Additional IAM role for the user
resource "aws_iam_role" "ci-custom-role" {
  provider           = aws.kendra
  name               = "ci-custom-role"
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
    Name = "ci-custom-role"
  }
}


resource "aws_iam_policy" "ci-custom-policy" {
  provider    = aws.kendra
  name        = "ci-custom-policy"
  description = "Custom policy for ci-custom-role"
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
        "iam:*"
      ],
      "Resource": "*"
    },
  ]
}
EOF
}

# Attach the custom policy to the ci-custom-role
resource "aws_iam_role_policy_attachment" "ci-custom-policy-attach" {
  provider   = aws.kendra
  role       = aws_iam_role.ci-custom-role.name
  policy_arn = aws_iam_policy.ci-custom-policy.arn
}









