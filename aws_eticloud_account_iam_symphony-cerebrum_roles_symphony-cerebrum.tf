resource "aws_iam_role" "symphony-cerebrum" {
  name = "symphony-cerebrum"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::626007623524:saml-provider/cloudsso.cisco.com"
        },
        "Action" : "sts:AssumeRoleWithSAML",
        "Condition" : {
          "StringEquals" : {
            "SAML:aud" : "https://signin.aws.amazon.com/saml"
          }
        }
      },
      {
        "Sid" : "TrustPolicyStatementThatAllowsEC2ServiceToAssumeTheAttachedRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "symphony-cerebrum"
  }
}

resource "aws_iam_role" "syc-server-k8s-dev" {
  name = "syc-server-k8s-dev"

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
            "oidc.eks.us-east-2.amazonaws.com/id/E0C6C89945F38AA7EB162DA79ED9A00F:sub" : "system:serviceaccount:syc-server-dev-*:*syc-server-dev*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "syc-server-k8s-dev"
  }
}

resource "aws_iam_role" "syc-server-k8s-staging" {
  name = "syc-server-k8s-staging"

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
            "oidc.eks.us-east-2.amazonaws.com/id/BE8C746125841FB788C37D5EE11D39BD:sub" : "system:serviceaccount:syc-server-staging-*:*syc-server-staging*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "syc-server-k8s-staging"
  }
}

data "aws_iam_policy" "s3-syc-readonly" {
  name = "s3-syc-readonly"
}

data "aws_iam_policy" "ecr-syc-ro" {
  name = "ecr-syc-ro"
}

data "aws_iam_policy" "s3-syc-rw" {
  name = "s3-syc-rw"
}

data "aws_iam_policy" "cross-ac-access" {
  name = "cross_ac_access"
}

data "aws_iam_policy" "secretsmanager-syc-rw" {
  name = "secretsmanager-syc-rw"
}

data "aws_iam_policy" "iam-syc-ro" {
  name = "iam-syc-ro"
}

###### SSO Access #######

resource "aws_iam_role_policy_attachment" "syc-s3-policy-attachment" {
  role       = aws_iam_role.symphony-cerebrum.name
  policy_arn = data.aws_iam_policy.s3-syc-readonly.arn
}

resource "aws_iam_role_policy_attachment" "syc-ecr-policy-attachment" {
  role       = aws_iam_role.symphony-cerebrum.name
  policy_arn = data.aws_iam_policy.ecr-syc-ro.arn
}

resource "aws_iam_role_policy_attachment" "syc-s3-rw-policy-attachment" {
  role       = aws_iam_role.symphony-cerebrum.name
  policy_arn = data.aws_iam_policy.s3-syc-rw.arn
}

resource "aws_iam_role_policy_attachment" "syc-iam-ro-policy-attachment" {
  role       = aws_iam_role.symphony-cerebrum.name
  policy_arn = data.aws_iam_policy.iam-syc-ro.arn
}

###### Dev K8s #######

resource "aws_iam_role_policy_attachment" "syc-server-k8s-policy-attachment" {
  role       = aws_iam_role.syc-server-k8s-dev.name
  policy_arn = data.aws_iam_policy.s3-syc-rw.arn
}

resource "aws_iam_role_policy_attachment" "syc-server-k8s-cross-ac-policy-attachment" {
  role       = aws_iam_role.syc-server-k8s-dev.name
  policy_arn = data.aws_iam_policy.cross-ac-access.arn
}

resource "aws_iam_role_policy_attachment" "syc-secretsmanager-policy-attachment" {
  role       = aws_iam_role.symphony-cerebrum.name
  policy_arn = data.aws_iam_policy.secretsmanager-syc-rw.arn
}

resource "aws_iam_role_policy_attachment" "syc-server-secretsmanager-policy-attachment" {
  role       = aws_iam_role.syc-server-k8s-dev.name
  policy_arn = data.aws_iam_policy.secretsmanager-syc-rw.arn
}

###### Staging K8s #######

resource "aws_iam_role_policy_attachment" "syc-server-k8s-policy-attachment-staging" {
  role       = aws_iam_role.syc-server-k8s-staging.name
  policy_arn = data.aws_iam_policy.s3-syc-rw.arn
}
