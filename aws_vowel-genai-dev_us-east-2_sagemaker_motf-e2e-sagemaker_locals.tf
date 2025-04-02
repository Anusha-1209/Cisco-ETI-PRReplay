locals {
  account_id = data.aws_caller_identity.current.account_id
  name     = "motf-e2e-sagemaker"
  vpc_name = "motf-e2e-use2-1"
}
