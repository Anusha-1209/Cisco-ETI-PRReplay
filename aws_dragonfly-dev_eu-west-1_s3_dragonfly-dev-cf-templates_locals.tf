locals {
  aws_account_name = "dragonfly-dev"
  aws_region = "eu-west-1"

  bucket_name = "${local.aws_account_name}-cf-templates"
}
