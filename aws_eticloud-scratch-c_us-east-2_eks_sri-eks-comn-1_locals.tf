# This file was created by Outshift Platform Self-Service automation.
locals {
  name            = "sri-eks-comn-1"
  region          = "us-east-2"
  eks_aws_account = "eticloud-scratch-c"
  vpc_cidr        = "10.98.0.0/16"
  account_id      = data.aws_caller_identity.current.account_id
}
