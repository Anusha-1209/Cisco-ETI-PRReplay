# IAM role and policy required to write in the Rosey related bucket

data "aws_caller_identity" "current" {
  # region should not matter here, we use it to fetch the account ID
  provider = aws.us
}

# https://github.com/hashicorp/terraform/issues/24476
# Cannot use for_each to trim the below configuration, each resource is region bound

resource "aws_iam_policy" "rosey_logs_us" {
  provider    = aws.us
  name        = "RoseyLogs-us"
  description = "IAM Policy required in order to write to the Rosey-logs-us bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "stsAssumeRoleWithWebIdentityLogs",
        Effect = "Allow",
        Action = [
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = [
          "arn:aws:iam::${local.account_id}:role/${aws_iam_role.rosey_logs_us.name}"
        ]
      },
      {
        Sid    = "S3AccessToSpecificBucket",
        Effect = "Allow",
        Action = [
          "s3:*Object"
        ],
        Resource = [
          "arn:aws:s3:::rosey-logs-us/*",
          "arn:aws:s3:::rosey-logs-us",
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "rosey_logs_eu" {
  provider    = aws.eu
  name        = "RoseyLogs-us"
  description = "IAM Policy required in order to write to the Rosey-logs-eu bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "stsAssumeRoleWithWebIdentityLogs",
        Effect = "Allow",
        Action = [
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = [
          "arn:aws:iam::${local.account_id}:role/${aws_iam_role.rosey_logs_eu.name}"
        ]
      },
      {
        Sid    = "S3AccessToSpecificBucket",
        Effect = "Allow",
        Action = [
          "s3:*Object"
        ],
        Resource = [
          "arn:aws:s3:::rosey-logs-eu/*",
          "arn:aws:s3:::rosey-logs-eu",
        ]
      }
    ]
  })
}

resource "aws_iam_role" "rosey_logs_us" {
  provider = aws.us
  name     = "RoseyLogs-us"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.account_id}:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/EFF9B51923E64F3067C820180603F855"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/EFF9B51923E64F3067C820180603F855:aud" = "sts.amazonaws.com"
            "oidc.eks.us-east-2.amazonaws.com/id/EFF9B51923E64F3067C820180603F855:sub" = "system:serviceaccount:opentelemetry-exporter:*opentelemetry*"
          }
        }
      }
    ]
  })

  force_detach_policies = false
}

resource "aws_iam_role" "rosey_logs_eu" {
  provider = aws.eu
  name     = "RoseyLogs-eu"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.account_id}:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/..."
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.eu-central-1.amazonaws.com/id/EFF9B51923E64F3067C820180603F855:aud" = "sts.amazonaws.com"
            "oidc.eks.eu-central-1.amazonaws.com/id/EFF9B51923E64F3067C820180603F855:sub" = "system:serviceaccount:opentelemetry-exporter:*opentelemetry*"
          }
        }
      }
    ]
  })

  force_detach_policies = false
}

resource "aws_iam_role_policy_attachment" "rosey_logs_us" {
  provider   = aws.us
  role       = aws_iam_role.rosey_logs_us.name
  policy_arn = aws_iam_policy.rosey_logs_us.arn
}

resource "aws_iam_role_policy_attachment" "rosey_logs_eu" {
  provider   = aws.eu
  role       = aws_iam_role.rosey_logs_eu.name
  policy_arn = aws_iam_policy.rosey_logs_eu.arn
}
