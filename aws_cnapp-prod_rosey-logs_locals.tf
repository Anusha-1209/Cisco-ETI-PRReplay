locals {
  account_id       = data.aws_caller_identity.current.account_id
  account_name     = "cnapp-prod"
  application_name = "opentelemetry-exporter"
  # EKS clsuter region and OIDC provider id
  clusters = {
    "cnapp-prod-us" = {
      name             = "cnapp-prod-use2-1"
      region           = "us-east-2"
      region_prefix    = "us"
      oidc_provider_id = "EFF9B51923E64F3067C820180603F855"
    }
  }
}
