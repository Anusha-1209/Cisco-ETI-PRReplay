data "aws_caller_identity" "current" {
  provider = aws.marvin
}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

#region Create the IAM user secret engine will use to auth against AWS
resource "aws_iam_user" "vault-secret-engine-user-marvin" {
  provider = aws.marvin
  name     = "vault-secret-engine-user-marvin"
}

resource "aws_iam_access_key" "vault-secret-engine-user-marvin" {
  provider = aws.marvin
  user     = aws_iam_user.vault-secret-engine-user-marvin.name
}

resource "aws_iam_user_policy" "vault-secret-engine-user-marvin" {
  provider = aws.marvin
  name     = "vault-secret-engine-user-marvin"
  user     = aws_iam_user.vault-secret-engine-user-marvin.name
  policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "${aws_iam_role.ci-default-role.arn}",
        "${aws_iam_role.ci-s3-push.arn}",
        "${aws_iam_role.ci-custom-role.arn}"
      ]
    }
  ]
}
EOF
  
}
#endregion

#region ci-s3-push role and policy
resource "aws_iam_role" "ci-s3-push" {
  provider           = aws.marvin
  name               = "ci-s3-push"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.vault-secret-engine-user-marvin.arn}"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ci-s3-push"
  }
}

resource "aws_iam_policy" "ci-s3-write-policy" {
  provider    = aws.marvin
  name        = "ci-s3-write-policy"
  description = "write access to S3 storage"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::marvin-prod"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::marvin-prod/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ci-s3-write-policy-attach" {
  provider   = aws.marvin
  role       = aws_iam_role.ci-s3-push.name
  policy_arn = aws_iam_policy.ci-s3-write-policy.arn
}
#endregion

#region ci-default role and policy attachments
resource "aws_iam_role" "ci-default-role" {
  provider           = aws.marvin
  name               = "ci-default"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.vault-secret-engine-user-marvin.arn}"
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

resource "aws_iam_role_policy_attachment" "ci-default-s3-write-policy-attach" {
  provider   = aws.marvin
  role       = aws_iam_role.ci-default-role.name
  policy_arn = aws_iam_policy.ci-s3-write-policy.arn
}
#endregion
# Existing Terraform configuration...

# Additional IAM role for the user
resource "aws_iam_role" "ci-custom-role" {
  provider           = aws.marvin
  name               = "ci-custom-role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Effect" : "Allow",
        "Principal" : {
        "AWS" : "${aws_iam_user.vault-secret-engine-user-marvin.arn}"
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
  provider    = aws.marvin
  name        = "ci-custom-policy"
  description = "Custom policy for ci-custom-role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*"
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
        "iam:GetRole",
        "iam:DeleteRole",
        "iam:PassRole",
        "iam:DeleteRolePolicy"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "apigateway:*"
      ],
      "Resource": "arn:aws:apigateway:*::/*"
    }
  ]
}
EOF
}

# Attach the custom policy to the ci-custom-role
resource "aws_iam_role_policy_attachment" "ci-custom-policy-attach" {
  provider   = aws.marvin
  role       = aws_iam_role.ci-custom-role.name
  policy_arn = aws_iam_policy.ci-custom-policy.arn
}

