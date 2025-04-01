locals {
  account_id   = data.aws_caller_identity.current.account_id
  account_name = "cnapp-prod"
  # EKS clsuter region and OIDC provider id
  clusters = {
    "cnapp-prod-us" = {
      name             = "cnapp-prod-use2-1"
      region           = "us-east-2"
      region_prefix    = "us"
      oidc_provider_id = "EFF9B51923E64F3067C820180603F855"
    }
    "cnapp-prod-eu" = {
      name             = "cnapp-prod-euc1-1"
      region           = "eu-central-1"
      region_prefix    = "eu"
      oidc_provider_id = "28A49D0DC19E0AE06F2E38C0AD473F7D"
    }
  }
}
