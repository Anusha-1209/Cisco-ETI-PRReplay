locals {
  # AWS account
  aws_account        = "dragonfly-dev"

  # Role description
  role_description   = "IAM Role for msk connect kg execution role"

  # AWS MSK Cluster
  dragonfly_msk_cluster_name = "dragonfly-msk-1"

  # Logs bucket
  arangodb_connector_logs_bucket    = "dragonfly-dev-kafka-connector-log-files"

  # Regions
  regions = {
    "euw1" = "eu-west-1",
  }
}
