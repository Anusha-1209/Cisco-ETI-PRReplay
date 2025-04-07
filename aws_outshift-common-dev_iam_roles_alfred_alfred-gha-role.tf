
resource "aws_iam_policy" "gha_alfred_role_policy" {
  name        = "gha-alfred-policy"
  description = "IAM Policy to grant GHA permissions to deploy Lambda"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Lambda",
        "Effect" : "Allow",
        "Action" : [
          "lambda:*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:*",
        "Resource" : "*"
      },
    ]
  })
}

resource "aws_iam_role" "gha_alfred_role_role" {
  name = "gha-alfred-role"
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
            "token.actions.githubusercontent.com:sub" : "repo:cisco-eti/alfred:*"
          }
        }
      }
    ]
  })

  force_detach_policies = false
}

resource "aws_iam_role_policy_attachment" "gha_alfred_role_policy_attachment" {
  role       = aws_iam_role.gha_alfred_role_role.name
  policy_arn = aws_iam_policy.gha_alfred_role_policy.arn
}
