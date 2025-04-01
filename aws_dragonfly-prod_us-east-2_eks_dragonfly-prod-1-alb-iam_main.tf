locals {
  account_id = data.aws_caller_identity.current.account_id
  oidc_id    = trimprefix(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_policy" "aws_alb_controller_policy" {
  name        = "${var.cluster_name}-aws-alb-controller-policy"
  description = "${var.cluster_name} AWS ALB Controller Role IAM Policy"
  policy      = file("./resources/aws_alb_controller_policy.json")
}

resource "aws_iam_role" "aws_alb_controller_role" {
  name = "${var.cluster_name}-aws-alb-controller-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_id}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_id}:aud" : "sts.amazonaws.com",
            "${local.oidc_id}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
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
