locals {
  aws_account_name = "dragonfly-prod"
  aws_region = "eu-central-1"

  bucket_name = "${local.aws_account_name}-euc1--kafka-connector-log-files"
}
