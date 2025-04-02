locals {
  aws_account_name                 = "dragonfly-dev"
  arangodb_connector_plugin_name     = "kafka-connect-arangodb-1-2-0-dragonfly-2"
  arangodb_connector_logs_bucket   = "dragonfly-dev-kafka-connector-log-files"
  arangodb_connector_plugin_bucket = "dragonfly-dev-binaries-repository"
}
