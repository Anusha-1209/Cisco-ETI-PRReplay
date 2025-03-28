data "aws_caller_identity" "current" {}

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
        Resource = "arn:aws:s3:::outshift-product-analytics-s3-bucket/Rosey/*"
      },
      {
        Sid    = "AllObjectActions",
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::outshift-product-analytics-s3-bucket/Rosey"
      }
    ]
  })
}

module "iam_eks_role_plg_s3" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "5.39.0"
  for_each  = local.cnapp_clusters
  role_name = "WriteToS3-${each.key}-Rosey"

  role_policy_arns = {
    policy = aws_iam_policy.plg_write_to_s3.arn
  }

  oidc_providers = {
    "${each.key}" = {
      provider_arn               = "arn:aws:iam::${local.aws_account_id}:oidc-provider/${each.value.eks_oidc}"
      namespace_service_accounts = ["rosey*:rosey*"]
    }
  }
}
