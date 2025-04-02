locals {
  account_name = "motific-prod"
  account_id = data.aws_caller_identity.current.account_id
}
