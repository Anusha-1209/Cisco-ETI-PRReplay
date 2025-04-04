data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks" {
  name       = local.name
  provider   = aws.eks
  depends_on = [module.eks_all_in_one]
}

data "aws_eks_cluster_auth" "eks" {
  name       = local.name
  provider   = aws.eks
  depends_on = [module.eks_all_in_one]
}