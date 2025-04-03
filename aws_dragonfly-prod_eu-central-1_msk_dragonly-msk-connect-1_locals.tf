locals {
  aws_account_name = "dragonfly-production"

  compute_vpc = "dragonfly-prod-euc1-1"
  data_vpc    = "dragonfly-prod-data-euc1-1"

  arangodb_connector_plugin_name   = "kafka-connect-arangodb-1-2-0-dragonfly-5"
  arangodb_connector_logs_bucket   = "dragonfly-prod-euc1-kafka-connector-log-files"
  arangodb_connector_plugin_bucket = "dragonfly-prod-euc1-binaries-repository"
  arangodb_connector_plugin_jar    = "kafka-connect-arangodb-1.2.0-dragonfly-5.zip"
}
