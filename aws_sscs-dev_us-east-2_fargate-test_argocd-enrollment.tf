module "argocd" {
  source              = "git::https://github.com/cisco-eti/sre-tf-module-argo-cluster-enrollment?ref=0.1.0"
  argocd_cluster_name = "eks-gitops-cnapp-1"
  eks_cluster_name    = var.eks_name
  providers = {
    aws.eks = aws.eks
    aws.argocd = aws.argocd
  }
}