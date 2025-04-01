# IAM role and policy required to write in the Rosey related bucket

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "rosey_logs" {
  for_each    = local.clusters
  name        = "RoseyLogs-${substr(each.key, 0, 2)}"
  description = "IAM Policy required in order to write to the rosey-logs-${substr(each.key, 0, 2)} bucket"
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
          "arn:aws:iam::${local.account_id}:role/${aws_iam_role.rosey_logs[each.key].name}"
        ]
      },
      {
        Sid    = "S3AccessToSpecificBucket",
        Effect = "Allow",
        Action = [
          "s3:*Object"
        ],
        Resource = [
          "arn:aws:s3:::rosey-logs-${substr(each.key, 0, 2)}/*",
          "arn:aws:s3:::rosey-logs-${substr(each.key, 0, 2)}",
        ]
      }
    ]
  })
}

resource "aws_iam_role" "rosey_logs" {
  for_each = local.clusters
  name     = "RoseyLogs-${substr(each.key, 0, 2)}"
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
  policy_arn = aws_iam_policy.rosey_logs[each.key].arn
}
