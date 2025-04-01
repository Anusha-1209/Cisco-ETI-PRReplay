# IAM role and policy required to write in the Rosey related bucket

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "rosey_logs" {
  for_each    = local.clusters
  name        = "RoseyLogs-${each.value.region_prefix}"
  description = "IAM Policy required in order to write to the rosey-logs-${each.value.region_prefix} bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ListObjectsInBucket",
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::rosey-logs-${each.value.region_prefix}"
        ]
      },
      {
        Sid    = "S3AccessToSpecificBucket",
        Effect = "Allow",
        Action = [
          "s3:*Object"
        ],
        Resource = [
          "arn:aws:s3:::rosey-logs-${each.value.region_prefix}/*",
          "arn:aws:s3:::rosey-logs-${each.value.region_prefix}",
        ]
      }
    ]
  })
}

resource "aws_iam_role" "rosey_logs" {
  for_each = local.clusters
  name     = "RoseyLogs-${each.value.region_prefix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.account_id}:oidc-provider/oidc.eks.${each.value.region}.amazonaws.com/id/${each.value.oidc_provider_id}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.${each.value.region}.amazonaws.com/id/${each.value.oidc_provider_id}:aud" = "sts.amazonaws.com"
            "oidc.eks.${each.value.region}.amazonaws.com/id/${each.value.oidc_provider_id}:sub" = "system:serviceaccount:opentelemetry-exporter:${each.value.name}-opentelemetry-exporter"
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
