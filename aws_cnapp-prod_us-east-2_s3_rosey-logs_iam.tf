# IAM role and policy required to write in the Rosey related bucket

data "aws_caller_identity" "current" {}

locals {
  account_id   = data.aws_caller_identity.current.account_id
  account_name = "cnapp-prod"
  clusters = {
    "us-east-2"    = "EFF9B51923E64F3067C820180603F855"
    "eu-central-1" = "28A49D0DC19E0AE06F2E38C0AD473F7D"
  }
}

resource "aws_iam_policy" "rosey_logs" {
  name        = "roseyLogs"
  description = "IAM Policy required in order to write to the rosey-logs bucket"
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
          "arn:aws:iam::${local.account_id}:role/${aws_iam_role.rosey_logs.name}"
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
          "arn:aws:s3:::rosey-logs-eu/*",
          "arn:aws:s3:::rosey-logs-eu"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "rosey_logs" {
  for_each = local.clusters
  name     = "RoseyLogs-${each.key}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.account_id}:oidc-provider/oidc.eks.${each.key}.amazonaws.com/id/${each.value}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${each.key}.amazonaws.com/id/${each.value}:aud" = "sts.amazonaws.com"
            "oidc.eks.${each.key}.amazonaws.com/id/${each.value}:sub" = "system:serviceaccount:opentelemetry-exporter:*opentelemetry*"
          }
        }
      }
    ]
  })

  force_detach_policies = false
}

resource "aws_iam_role_policy_attachment" "rosey_logs" {
  for_each   = local.clusters
  role       = aws_iam_role.rosey_logs[each.key].name
  policy_arn = aws_iam_policy.rosey_logs.arn
}
