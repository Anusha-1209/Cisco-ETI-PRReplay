locals {
  aws_account_name = "dragonfly-staging"
  aws_region = "eu-west-1"

  bucket_name = "dragonfly-staging-data"
  eks_oidc_provider_id = "28C9314DBD532A08FF0B98E387A4A19F"
  msk_cluster_name = "dragonfly-staging-msk-1" # A
}
