data "aws_caller_identity" "current" {}

locals {
  aws_account_id                = "730335524490"
  # cnapp prod clusters
  cnapp_prod_clusters_oidc_ids = [
    "28A49D0DC19E0AE06F2E38C0AD473F7D", "EFF9B51923E64F3067C820180603F855"
  ]
}

# IAM policy that allows to list a specific bucket and write objects to it

resource "aws_iam_policy" "plg_write_to_s3" {
  name        = "WriteToPLGAnalyticsS3Bucket"
  description = "IAM policy that allows to write to a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ListObjectsInBucket",
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::eti-plg-analytics-s3-bucket/Rosey/*"
      },
      {
        Sid    = "AllObjectActions",
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::eti-plg-analytics-s3-bucket/Rosey"
      }
    ]
  })
}

# 
resource "aws_iam_role" "plg_write_to_s3" {
  name = "WriteToPLGAnalyticsS3Bucket"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EKSAssumeRolePolicyToS3"
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.aws_account_id}:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/${[for cluster_oidc in cnapp_prod_clusters_oidc_ids: cluster_oidc]}",
        },
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/${[for cluster_oidc in cnapp_prod_clusters_oidc_ids: cluster_oidc]}:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-2.amazonaws.com/id/${[for cluster_oidc in cnapp_prod_clusters_oidc_ids: cluster_oidc]}:sub" : "system:serviceaccount:rosey*:rosey*"
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amp_ingest_policy" {
  role       = aws_iam_role.plg_write_to_s3.name
  policy_arn = aws_iam_policy.plg_write_to_s3.arn
}
