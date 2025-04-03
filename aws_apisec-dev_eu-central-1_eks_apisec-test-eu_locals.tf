# This file was created by Outshift Platform Self-Service automation.
locals {
  name               = "apisec-test-eu"
  region             = "eu-central-1"
  eks_aws_account    = "apisec-dev"
  vpc_cidr           = "10.0.0.0/16"
  argocd_k8s_name    = "eks-dev-gitops-1"
  argocd_aws_account = "eticloud-preprod"
}
