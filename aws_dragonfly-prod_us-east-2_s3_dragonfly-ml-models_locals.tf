locals {
  aws_account_name = "dragonfly-prod"
  aws_region = "eu-west-1"

  bucket_name = "${local.aws_account_name}-ml-models"
}
