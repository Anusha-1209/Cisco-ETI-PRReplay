# This file was created by Outshift Platform Self-Service automation.
locals {
  name               = "apisec-systest-dev"
  region             = "us-east-2"
  eks_aws_account    = "apisec-dev"
  vpc_cidr           = "10.10.0.0/16"
  argocd_k8s_name    = "eks-dev-gitops-1"
  argocd_aws_account = "eticloud-preprod"
}
