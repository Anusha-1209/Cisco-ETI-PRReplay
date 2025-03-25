data "aws_eks_cluster" "cluster_s3" {
  name = local.cluster_name_s3
}

data "aws_caller_identity" "current_s3" {}

locals {
  cluster_name_s3 = "eks-dev-4" # The name of the associated EKS cluster. Must be updated
  account_id_s3   = data.aws_caller_identity.current_s3.account_id
  oidc_id_s3      = trimprefix(data.aws_eks_cluster.cluster_s3.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_policy" "aws_s3_admin_policy" {
  name        = "${local.cluster_name_s3}-aws-s3-admin-policy"
  description = "${local.cluster_name_s3} AWS S3 Admin Role IAM Policy"
  policy      = file("./resources/aws_s3_admin_policy.json")
}

resource "aws_iam_role" "aws_s3_admin_role" {
  name = "${local.cluster_name_s3}-s3-admin-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${local.account_id_s3}:oidc-provider/${local.oidc_id_s3}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${local.oidc_id_s3}:aud" : "sts.amazonaws.com",
            "${local.oidc_id_s3}:sub" : "system:serviceaccount:ppu-labelstud:labelstud-ls-app"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_s3_admin_attachment" {
  role       = aws_iam_role.aws_s3_admin_role.name
  policy_arn = aws_iam_policy.aws_s3_admin_policy.arn
}