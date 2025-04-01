data "aws_caller_identity" "current" {
  provider = aws.synthetica-dev
}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

#region Create the IAM user secret engine will use to auth against AWS
resource "aws_iam_user" "vault-secret-engine-user-synthetica-dev" {
  provider = aws.synthetica-dev
  name     = "vault-secret-engine-user-synthetica-dev"
}

resource "aws_iam_access_key" "vault-secret-engine-user-synthetica-dev" {
  provider = aws.synthetica-dev
  user     = aws_iam_user.vault-secret-engine-user-synthetica-dev.name
}

resource "aws_iam_user_policy" "vault-secret-engine-user-synthetica-dev" {
  provider = aws.synthetica-dev
  name     = "vault-secret-engine-user-synthetica-dev"
  user     = aws_iam_user.vault-secret-engine-user-synthetica-dev.name
  policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "${aws_iam_role.ci-default-role.arn}",
        "${aws_iam_role.ci-ecr-access.arn}"
      ]
    }
  ]
}
EOF
}
#endregion

#region ci-ecr-access role and policy
resource "aws_iam_role" "ci-ecr-access" {
  provider           = aws.synthetica-dev
  name               = "ci-ecr-access"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.vault-secret-engine-user-synthetica-dev.arn}"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "ci-ecr-access"
  }
}

resource "aws_iam_policy" "ci-ecr-access-policy" {
  provider    = aws.synthetica-dev
  name        = "ci-ecr-access-policy"
  description = "ECR access"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "ecr:UploadLayerPart",
                "ecr:PutImage",
                "ecr:ListTagsForResource",
                "ecr:ListImages",
                "ecr:InitiateLayerUpload",
                "ecr:CreateRepository",
                "ecr:GetRepositoryPolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:GetLifecyclePolicy",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken",
                "ecr:DescribeRepositories",
                "ecr:DescribeImages",
                "ecr:DescribeImageScanFindings",
                "ecr:CompleteLayerUpload",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy_attachment" "ci-ecr-access-policy-attach" {
  provider   = aws.synthetica-dev
  role       = aws_iam_role.ci-ecr-access.name
  policy_arn = aws_iam_policy.ci-ecr-access-policy.arn
}
#endregion

#region ci-default role and policy attachments
resource "aws_iam_role" "ci-default-role" {
  provider           = aws.synthetica-dev
  name               = "ci-default"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.account_id}:user/vault-secret-engine-user-synthetica-dev"
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
  provider   = aws.synthetica-dev
  role       = aws_iam_role.ci-default-role.name
  policy_arn = aws_iam_policy.ci-ecr-access-policy.arn
}
#endregion
