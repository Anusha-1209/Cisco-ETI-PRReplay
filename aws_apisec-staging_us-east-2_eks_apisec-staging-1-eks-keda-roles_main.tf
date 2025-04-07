data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
data "aws_eks_cluster" "cluster" {
  name = var.eks_name
}
locals {
  account_id = data.aws_caller_identity.current.account_id
  region_id = data.aws_region.current.name
  oidc_id    = trimprefix(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")
}

resource "aws_iam_policy" "aws_keda_policy" {
  name        = "KedaPolicy-${var.eks_name}"
  description = "${var.eks_name} AWS Keda Role IAM Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "sqs:GetQueueAttributes",
                "sqs:GetQueueAttributes",
                "sqs:GetQueueUrl",
                "sqs:ListDeadLetterSourceQueues",
                "sqs:ListQueues",
            ],
            "Resource": "*"
        }
    ]
    })
 }

resource "aws_iam_role" "aws_keda_role" {
  name = "KedaRole-${var.eks_name}"
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
            "${local.oidc_id}:aud" : "sts.amazonaws.com"
            "${local.oidc_id}:sub" : "system:serviceaccount:keda:keda-operator"
          }
        }
      }
    ]
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "aws_keda_attachment" {
  role       = aws_iam_role.aws_keda_role.name
  policy_arn = aws_iam_policy.aws_keda_policy.arn
}
