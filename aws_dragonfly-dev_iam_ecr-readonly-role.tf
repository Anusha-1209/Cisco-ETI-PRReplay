########################################################
#                                                      #
#  IAM roles (RO) for service account (IRSA) of ECR    #
#                                                      #
########################################################

#################################
# ECR Read Only Access 
#################################

locals {
  eks_cluster_name = "eks-dragonfly-dev-2"
  aws_account_id   = "474213319131"
  eks_oidc         = "oidc.eks.eu-west-1.amazonaws.com/id/AEE5EF78D8DBE429EB35271E41F3AC72AWS"
  service_account  = "dragonfly-backend:dragonfly-art-a-dev-app"
  resources_names  = ["dragonfly/datamodel/*", "dragonfly/kg-plugin/*", "dragonfly/falco-rules/*"]
}

# IAM Role
resource "aws_iam_role" "eks_irsa_ecr_ro" {

  name = "${local.eks_cluster_name}-eks-irsa-ecr-ro"
  assume_role_policy = templatefile("${path.module}/policies/assume_role_irsa.tpl", {
    aws_account_id  = local.aws_account_id
    eks_oidc        = local.eks_oidc
    service_account = local.service_account
  })
}

# IAM Policy
resource "aws_iam_policy" "eks_irsa_ecr_ro_policy" {

  name        = "${local.eks_cluster_name}-eks-irsa-ecr-ro-policy"
  description = "EKS IRSA secret access ECR policy"
  policy = templatefile("${path.module}/policies/ecr_readonly_policy.tpl", {
    resources = join("\"626007623524.dkr.ecr.us-east-2.amazonaws.com/,\"", local.resources_names)
  })
}

# IAM Policy Attachment
resource "aws_iam_policy_attachment" "eks_irsa_s3_ro_policy" {

  name       = "${local.eks_cluster_name}-eks-irsa-ecr-ro-attach"
  roles      = [aws_iam_role.eks_irsa_ecr_ro.name]
  policy_arn = aws_iam_policy.eks_irsa_ecr_ro_policy.arn
}
