# This file was created by Outshift Platform Self-Service automation.
locals {
  name               = "validate-baseapps"
  argocd_k8s_name    = "eks-dev-gitops-1"
  argocd_aws_account = "eticloud-preprod"
  region             = "us-east-2"
  aws_account_name   = "eticloud-scratch-c"
  vpc_cidr           = "10.0.0.0/16"
}
