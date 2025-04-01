data "aws_caller_identity" "current_alb" {}

data "aws_eks_cluster" "cluster_alb" {
  name = local.cluster_name_alb
}

locals {
  cluster_name_alb = "eks-df-staging-1"
  account_id_alb   = data.aws_caller_identity.current_alb.account_id
  oidc_id_alb      = trimprefix(data.aws_eks_cluster.cluster_alb.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_policy" "aws_alb_controller_policy" {
  name        = "${local.cluster_name_alb}-aws-alb-controller-policy"
  description = "${local.cluster_name_alb} AWS ALB Controller Role IAM Policy"
  policy      = file("./resources/eks-alb-controller-role-policy.json")
}

resource "aws_iam_role" "aws_alb_controller_role" {
  name = "${local.cluster_name_alb}-aws-alb-controller-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${local.account_id_alb}:oidc-provider/${local.oidc_id_alb}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_id_alb}:aud" : "sts.amazonaws.com",
            "${local.oidc_id_alb}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_alb_controller_attachment" {
  role       = aws_iam_role.aws_alb_controller_role.name
  policy_arn = aws_iam_policy.aws_alb_controller_policy.arn
}
