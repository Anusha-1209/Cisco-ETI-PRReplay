resource "aws_iam_role" "syc-metablocks-k8s-dev" {
  name = "syc-metablocks-k8s-dev"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::626007623524:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/E0C6C89945F38AA7EB162DA79ED9A00F"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "oidc.eks.us-east-2.amazonaws.com/id/E0C6C89945F38AA7EB162DA79ED9A00F:sub" : "system:serviceaccount:syc-metablocks-dev-*:*syc-metablocks-app-dev*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "syc-metablocks-k8s-dev"
  }
}

resource "aws_iam_role" "syc-metablocks-k8s-staging" {
  name = "syc-metablocks-k8s-staging"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::626007623524:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/BE8C746125841FB788C37D5EE11D39BD"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "oidc.eks.us-east-2.amazonaws.com/id/BE8C746125841FB788C37D5EE11D39BD:sub" : "system:serviceaccount:syc-metablocks-staging-*:*syc-metablocks-staging*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "syc-metablocks-k8s-staging"
  }
}

###### Dev K8s #######

resource "aws_iam_role_policy_attachment" "syc-metablocks-k8s-policy-attachment" {
  role       = aws_iam_role.syc-metablocks-k8s-dev.name
  policy_arn = data.aws_iam_policy.s3-syc-readonly.arn
}

###### Staging K8s #######

resource "aws_iam_role_policy_attachment" "syc-metablocks-k8s-policy-attachment-staging" {
  role       = aws_iam_role.syc-metablocks-k8s-staging.name
  policy_arn = data.aws_iam_policy.s3-syc-readonly.arn
}
