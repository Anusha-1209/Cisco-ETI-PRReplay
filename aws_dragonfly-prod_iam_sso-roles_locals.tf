locals {
  account_id = data.aws_caller_identity.current.account_id
  account_name = "dragonfly-prod"
}