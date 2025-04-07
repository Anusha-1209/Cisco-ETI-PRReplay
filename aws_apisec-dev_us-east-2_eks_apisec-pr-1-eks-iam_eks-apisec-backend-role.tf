data "aws_eks_cluster" "cluster_backend" {
  name = local.cluster_name_backend
}

data "aws_caller_identity" "current_backend" {}

locals {
  cluster_name_backend = "apisec-pr-1" # The name of the associated EKS cluster. Must be updated
  account_id_backend   = data.aws_caller_identity.current_backend.account_id
  oidc_id_backend      = trimprefix(data.aws_eks_cluster.cluster_backend.identity[0].oidc[0].issuer, "https://")
}  

resource "aws_iam_policy" "apisec_backend_policy" {
  name        = "${local.cluster_name_backend}-apisec-backend-policy"
  description = "${local.cluster_name_backend} apisec backend Role IAM Policy"
  policy      = file("./resources/apisec-backend-policy.json")
}

resource "aws_iam_role" "apisec_backend_role" {
  name = "${local.cluster_name_backend}-backend-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${local.account_id_backend}:oidc-provider/${local.oidc_id_backend}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${local.oidc_id_backend}:aud" : "sts.amazonaws.com",
            "${local.oidc_id_backend}:sub" : [
                        "system:serviceaccount:apisec-backend:aws-apisec-score-collector*",
                        "system:serviceaccount:apisec-backend:apisec-*",
                        "system:serviceaccount:apisec-backend:presync-job-sa",
                        "system:serviceaccount:apisec-backend:backend-*"
                    ]
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "apisec_backend_attachment" {
  role       = aws_iam_role.apisec_backend_role.name
  policy_arn = aws_iam_policy.apisec_backend_policy.arn
}