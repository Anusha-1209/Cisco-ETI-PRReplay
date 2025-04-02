locals {
  name             = "cspm-prod-use1-1"
  region           = "us-east-2"
  eks_aws_account_name = "lightspin-prod"
  argocd_k8s_name    = "eks-gitops-cnapp-1"
  argocd_k8s_region  = "eu-north-1"
  argocd_aws_account_name = "eti-ci"
}
