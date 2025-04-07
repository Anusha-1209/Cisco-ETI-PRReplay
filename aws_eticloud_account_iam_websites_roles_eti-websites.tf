resource "aws_iam_role" "websites-k8s-dev" {
  name = "websites-k8s-dev"

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
            "oidc.eks.us-east-2.amazonaws.com/id/E0C6C89945F38AA7EB162DA79ED9A00F:sub" : "system:serviceaccount:*website-dev*:*website-dev*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "websites-k8s-dev"
  }
}

resource "aws_iam_role" "websites-k8s-staging" {
  name = "websites-k8s-staging"

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
            "oidc.eks.us-east-2.amazonaws.com/id/BE8C746125841FB788C37D5EE11D39BD:sub" : "system:serviceaccount:*website-staging*:*website-staging*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "websites-k8s-staging"
  }
}

resource "aws_iam_role" "websites-k8s-prod" {
  name = "websites-k8s-prod"

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
            "oidc.eks.us-east-2.amazonaws.com/id/BE8C746125841FB788C37D5EE11D39BD:sub" : "system:serviceaccount:*website-prod*:*website-prod*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "websites-k8s-prod"
    Environment = "Prod"
  }
}

data "aws_iam_policy" "s3-websites-ro-dev" {
  name = "s3-websites-ro-dev"
}

data "aws_iam_policy" "s3-websites-ro-staging" {
  name = "s3-websites-ro-staging"
}

data "aws_iam_policy" "s3-websites-ro-prod" {
  name = "s3-websites-ro-prod"
}

###### Dev K8s #######

resource "aws_iam_role_policy_attachment" "websites-k8s-policy-attachment" {
  role       = aws_iam_role.websites-k8s-dev.name
  policy_arn = data.aws_iam_policy.s3-websites-ro-dev.arn
}

###### Staging K8s #######

resource "aws_iam_role_policy_attachment" "websites-k8s-policy-attachment-staging" {
  role       = aws_iam_role.websites-k8s-staging.name
  policy_arn = data.aws_iam_policy.s3-websites-ro-staging.arn
}

###### Prod K8s #######

resource "aws_iam_role_policy_attachment" "websites-k8s-policy-attachment-prod" {
  role       = aws_iam_role.websites-k8s-prod.name
  policy_arn = data.aws_iam_policy.s3-websites-ro-prod.arn
}
