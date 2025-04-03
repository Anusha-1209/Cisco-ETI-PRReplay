locals {
  name             = "cspm-staging-euw1-1"
  region           = "eu-west-1"
  eks_aws_account_name = "lightspin-staging"
  argocd_k8s_name    = "eks-gitops-cnapp-1"
  argocd_k8s_region  = "eu-north-1"
  argocd_aws_account_name = "eti-ci"
}