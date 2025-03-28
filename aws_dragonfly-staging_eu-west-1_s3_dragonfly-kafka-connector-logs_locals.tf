locals {
  aws_account_name = "dragonfly-staging"
  aws_region = "eu-west-1"

  bucket_name = "${local.aws_account_name}-kafka-connector-log-files"
}
