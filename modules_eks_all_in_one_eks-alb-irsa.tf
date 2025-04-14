resource "aws_iam_policy" "aws_alb_controller_policy" {
  count                 = var.create_alb_irsa ? 1 : 0
  name                  = "${local.name}-aws-alb-controller-policy"
  description           = "${local.name} AWS ALB Controller Role IAM Policy"
  policy                = file("${path.module}/resources/aws_alb_controller_policy.json")
}

resource "aws_iam_role" "aws_alb_controller_role" {
  count                 = var.create_alb_irsa ? 1 : 0
  name                  = "${local.name}-aws-alb-controller-role"
  assume_role_policy    = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_issuer}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_issuer}:aud" : "sts.amazonaws.com",
            "${local.oidc_issuer}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_alb_controller_attachment" {
  count                 = var.create_alb_irsa ? 1 : 0
  role                  = aws_iam_role.aws_alb_controller_role[0].name
  policy_arn            = aws_iam_policy.aws_alb_controller_policy[0].arn
}