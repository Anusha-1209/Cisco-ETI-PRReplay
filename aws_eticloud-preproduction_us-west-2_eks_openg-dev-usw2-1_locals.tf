# This file was created by Outshift Platform Self-Service automation.
locals {
  name               = "openg-dev-usw2-1"
  region             = "us-west-2"
  eks_aws_account    = "eticloud-preproduction"
  vpc_cidr           = "10.2.0.0/16"
  argocd_k8s_name    = "eks-dev-gitops-1"
  argocd_aws_account = "eticloud-preprod"
}
