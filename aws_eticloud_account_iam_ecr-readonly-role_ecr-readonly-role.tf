########################################################
#                                                      #
#  IAM roles (RO) for service account (IRSA) of ECR    #
#                                                      #
########################################################

#################################
# ECR Read Only Access
#################################
locals {
  aws_account_id = "626007623524"
  eks_irsa = {
    dragonfly = {
      eks-dragonfly-dev-2 = {
        eks_oidc          = "oidc.eks.eu-west-1.amazonaws.com/id/AEE5EF78D8DBE429EB35271E41F3AC72"
        eks_cluster_name  = "eks-dragonfly-dev-2"
        services_accounts = ["dragonfly-backend:dragonfly-art-a-dev-app"],
        resources_names   = ["dragonfly/datamodel/*", "dragonfly/kg-plugin/*", "dragonfly/falco-rules/*"]
      },
      eks-df-staging-1 = {
        eks_oidc          = "oidc.eks.eu-west-1.amazonaws.com/id/28C9314DBD532A08FF0B98E387A4A19F"
        eks_cluster_name  = "eks-df-staging-1"
        services_accounts = ["dragonfly-backend:dragonfly-art-a-staging-app"],
        resources_names   = ["dragonfly/datamodel/*", "dragonfly/kg-plugin/*", "dragonfly/falco-rules/*"]
      },
      dragonfly-prod-euc1-1 = {
        eks_oidc          = "oidc.eks.eu-central-1.amazonaws.com/id/1FB74EA8743EEA7992B0D95A4B404124"
        eks_cluster_name  = "dragonfly-prod-euc1-1"
        services_accounts = ["dragonfly-backend:dragonfly-art-a-prod-eu-app"],
        resources_names   = ["dragonfly/datamodel/*", "dragonfly/kg-plugin/*", "dragonfly/falco-rules/*"]
      },
      dragonfly-prod-1 = {
        eks_oidc          = "oidc.eks.us-east-2.amazonaws.com/id/2FD8E66654862C5EF1DF7DB83F35F7AD"
        eks_cluster_name  = "dragonfly-prod-1"
        services_accounts = ["dragonfly-backend:dragonfly-art-a-prod-app"],
        resources_names   = ["dragonfly/datamodel/*", "dragonfly/kg-plugin/*", "dragonfly/falco-rules/*"]
      },
    }
  }
}

# IAM Role
resource "aws_iam_role" "eks_irsa_ecr_ro" {
  for_each = local.eks_irsa != null ? lookup(local.eks_irsa, "dragonfly", {}) : {}

  name = "${local.eks_irsa["dragonfly"][each.key].eks_cluster_name}-eks-irsa-ecr-ro"
  assume_role_policy = templatefile("${path.module}/policies/assume_role_irsa.json", {
    aws_account_id = local.aws_account_id
    eks_oidc       = local.eks_irsa["dragonfly"][each.key].eks_oidc
    service_accounts = join(
      "\",\"",
      formatlist(
        "system:serviceaccount:%s",
        "${local.eks_irsa["dragonfly"][each.key].services_accounts}",
      ),
    )
  })
}

# IAM Policy
resource "aws_iam_policy" "eks_irsa_ecr_ro_policy" {
  for_each = local.eks_irsa != null ? lookup(local.eks_irsa, "dragonfly", {}) : {}

  name        = "${local.eks_irsa["dragonfly"][each.key].eks_cluster_name}-eks-irsa-ecr-ro-policy"
  description = "EKS IRSA secret access dragonfly ECR policy"
  policy = templatefile("${path.module}/policies/ecr_readonly_policy.json", {
    resources = join("\",\"", (formatlist("arn:aws:ecr:us-east-2:626007623524:repository/%s", "${local.eks_irsa["dragonfly"][each.key].resources_names}")))
  })
  lifecycle {
    ignore_changes = [ policy ]
  }
}

# IAM Policy Attachment
resource "aws_iam_policy_attachment" "eks_irsa_s3_ro_policy" {
  for_each = local.eks_irsa != null ? lookup(local.eks_irsa, "dragonfly", {}) : {}

  name       = "${local.eks_irsa["dragonfly"][each.key].eks_cluster_name}-eks-irsa-ecr-ro-attach"
  roles      = [aws_iam_role.eks_irsa_ecr_ro[each.key].name]
  policy_arn = aws_iam_policy.eks_irsa_ecr_ro_policy[each.key].arn
}