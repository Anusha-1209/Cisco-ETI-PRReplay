locals {
  name             = "cspm-dev-euw1-1"
  region           = "eu-west-1"
  eks_aws_account_name = "lightspin-dev"
  account_id      = data.aws_caller_identity.current.account_id
}