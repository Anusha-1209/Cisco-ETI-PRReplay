locals {
  name             = "cspm-dev-euw1-1"
  region           = "eu-west-1"
  eks_aws_account_name = "lightspin-dev"
  argocd_k8s_name    = "eks-gitops-cnapp-1"
  argocd_k8s_region  = "eu-north-1"
  argocd_aws_account_name = "eti-ci"
  bucket             = "eticloud-tf-state-nonprod"
  state_key          = "terraform-state/aws/${local.eks_aws_account_name}/${local.region}/eks/${local.name}.tfstate"
}