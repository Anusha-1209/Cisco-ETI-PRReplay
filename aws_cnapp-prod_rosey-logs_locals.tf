locals {
  account_id   = data.aws_caller_identity.current.account_id
  account_name = "cnapp-prod"
  clusters = {
    "us-east-2"    = "EFF9B51923E64F3067C820180603F855"
    "eu-central-1" = "28A49D0DC19E0AE06F2E38C0AD473F7D"
  }
}
