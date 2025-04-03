# This file was created by Outshift Platform Self-Service automation.
locals {
  name               = "openg-prod-usw2-1"
  region             = "us-west-2"
  eks_aws_account    = "eticloud"
  vpc_cidr           = "10.0.0.0/16"
  argocd_k8s_name    = "eks-gitops-1"
  argocd_aws_account = "eti-ci"
}
