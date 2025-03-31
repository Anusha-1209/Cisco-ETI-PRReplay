locals {
  account_id = data.aws_caller_identity.current.account_id
  name     = "motf-prod-sagemaker"
  vpc_name = "motf-prod-use2-1"
}
