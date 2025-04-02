locals {
  account_id = data.aws_caller_identity.current.account_id
  name     = "motf-dev-sagemaker"
  vpc_name = "motf-dev-use2-1"
}
