# This file was created by Outshift Platform Self-Service automation.
locals {
  name               = "motf-dev-use2-1"
  argocd_k8s_name    = "eks-gitops-genai-1"
  argocd_aws_account = "eti-ci"
  region             = "us-east-2"
  aws_account_name   = "vowel-dev-genai"
  vpc_cidr           = "10.4.0.0/16"
}
