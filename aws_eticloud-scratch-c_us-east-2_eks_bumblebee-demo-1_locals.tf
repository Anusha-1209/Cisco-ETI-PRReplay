# This file was created by Outshift Platform Self-Service automation.
locals {
  name               = "bumblebee-demo-1"
  region             = "us-east-2"
  eks_aws_account    = "eticloud-scratch-c"
  vpc_cidr           = "10.0.0.0/16"
  argocd_k8s_name    = "eks-dev-gitops-1"
  argocd_aws_account = "eticloud-preprod"
}
