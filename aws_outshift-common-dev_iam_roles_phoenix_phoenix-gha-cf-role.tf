
resource "aws_iam_policy" "gha_phoenix_cf_role_policy" {
  name        = "gha-phoenix-cf-policy"
  description = "IAM Policy to grant GHA permissions to create EKS clusters "
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "EKS",
        "Effect" : "Allow",
        "Action" : [
          "eks:*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "gha_phoenix_cf_role_role" {
  name = "gha-phoenix-cf-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::471112537430:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:cisco-eti/phoenix-csit:*"
          }
        }
      }
    ]
  })

  force_detach_policies = false
}

resource "aws_iam_role_policy_attachment" "gha_phoenix_cf_role_policy_attachment" {
  role       = aws_iam_role.gha_phoenix_cf_role_role.name
  policy_arn = aws_iam_policy.gha_phoenix_cf_role_policy.arn
}
