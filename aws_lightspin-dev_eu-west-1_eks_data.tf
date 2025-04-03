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

data "aws_eks_cluster" "argocd" {
  name       = local.argocd_k8s_name
  provider   = aws.argocd
  depends_on = [module.eks_all_in_one]
}

data "aws_eks_cluster_auth" "argocd" {
  name       = local.argocd_k8s_name
  provider   = aws.argocd
  depends_on = [module.eks_all_in_one]
}