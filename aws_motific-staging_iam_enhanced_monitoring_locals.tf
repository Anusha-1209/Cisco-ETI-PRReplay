locals {
  account_name = "motific-staging"
  account_id = data.aws_caller_identity.current.account_id
}
