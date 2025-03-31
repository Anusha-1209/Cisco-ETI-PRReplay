# This file was created by Outshift Platform Self-Service automation.
locals {
  name             = "validate-baseapps"
  argocd_k8s_name  = "eks-dev-gitops-1"
  region           = "us-east-2"
  aws_account_name = "eticloud-scratch-c"
  vpc_cidr         = "10.0.0.0/16"
  argocd_manager_service_account_name = "argocd-manager"
  argocd_manager_namespace            = "kube-system"
}
