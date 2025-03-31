locals {
  account_id = data.aws_caller_identity.current.account_id
  name     = "motf-staging-sagemaker"
  vpc_name = "motf-staging-use2-1"
}
