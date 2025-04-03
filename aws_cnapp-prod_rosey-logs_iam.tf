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
            "oidc.eks.${each.value.region}.amazonaws.com/id/${each.value.oidc_provider_id}:sub" = "system:serviceaccount:${local.application_name}:${each.value.name}-${local.application_name}"
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


# Sync data with outshift-product-analytics-s3-bucket S3 bucket located in eticloud-plg-prod account
resource "aws_iam_policy" "datasync_cnapp_prod" {
  name        = "WriteToPLGAnalyticsS3Bucket"
  description = "IAM policy that allows to sync data across 2 S3 buckets in 2 AWS accounts"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ListObjectsInBucket",
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ],
        Resource = "arn:aws:s3:::outshift-product-analytics-s3-bucket"
      },
      {
        Sid    = "AllObjectActions",
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging"
        ],
        Resource = "arn:aws:s3:::outshift-product-analytics-s3-bucket/Rosey/*"
      }
    ]
  })
}

resource "aws_iam_role" "datasync_cnapp_prod" {
  name = "DataSync-cnapp-prod"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "datasync.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
