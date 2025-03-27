locals {
  cluster_name_s3 = "pi-prod-use2-1" # The name of the associated EKS cluster. Must be updated
}
resource "aws_iam_policy" "aws_pi_prod_triton_s3_policy" {
  name        = "pi-prod-triton-s3-policy"
  description = " ${local.cluster_name_s3} AWS S3 Admin Role IAM Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor1",
        Effect = "Allow",
        Action = [
          "sts:AssumeRoleWithWebIdentity"
        ],
        Resource = [
          aws_iam_role.aws_pi_prod_triton_s3_role.arn
        ]
      },
      {
        Sid    = "FullS3Access",
        Effect = "Allow",
        Action = [
          "s3:prompt-intel-triton-production"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "aws_pi_prod_triton_s3_role" {
  name = "pi-prod-triton-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::058264538874:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/06C50AA8E04F72BD02243B0A49DCC8D8"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-2.amazonaws.com/id/06C50AA8E04F72BD02243B0A49DCC8D8:aud" = "sts.amazonaws.com"
            "oidc.eks.us-east-2.amazonaws.com/id/06C50AA8E04F72BD02243B0A49DCC8D8:sub" = "system:serviceaccount:triton-s3-sa"
          }
        }
      }
    ]
  })

  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_pi_prod_triton_s3_policy_attachment" {
  role       = aws_iam_role.aws_pi_prod_triton_s3_role.name
  policy_arn = aws_iam_policy.aws_pi_prod_triton_s3_policy.arn
}
