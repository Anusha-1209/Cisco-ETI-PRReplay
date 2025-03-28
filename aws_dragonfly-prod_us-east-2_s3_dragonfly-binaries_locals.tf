locals {
  aws_account_name = "dragonfly-prod"
  aws_region = "us-east-2"

  bucket_name = "${local.aws_account_name}-binaries-repository"
}
