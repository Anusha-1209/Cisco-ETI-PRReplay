# This file was created by Outshift Platform Self-Service automation.
locals {
  name            = "test-boolean-cluster"
  region          = "eu-west-2"
  eks_aws_account = "outshift-common-dev"
  vpc_cidr        = "10.0.0.0/16"
  account_id      = data.aws_caller_identity.current.account_id
}
