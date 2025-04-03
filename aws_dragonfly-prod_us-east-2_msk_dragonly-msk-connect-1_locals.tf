locals {
  aws_account_name = "dragonfly-production"

  compute_vpc = "dragonfly-compute-prod-1-vpc"
  data_vpc    = "dragonfly-data-prod-1-vpc"

  arangodb_connector_plugin_name   = "kafka-connect-arangodb-1-2-0-dragonfly-5"
  arangodb_connector_logs_bucket   = "dragonfly-prod-kafka-connector-log-files"
  arangodb_connector_plugin_bucket = "dragonfly-prod-binaries-repository"
  arangodb_connector_plugin_jar    = "kafka-connect-arangodb-1.2.0-dragonfly-5.zip"
}
