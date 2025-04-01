locals {
  app_name = "dragonfly-dev"
  aws_account_name = "dragonfly-dev"
  aws_region       = "eu-west-1"
  account_id       = data.aws_caller_identity.current.account_id

  vpc_id = "dragonfly-dev-2-vpc"
}
