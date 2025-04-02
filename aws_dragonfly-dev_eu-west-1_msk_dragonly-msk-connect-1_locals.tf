locals {
  aws_account_name                 = "dragonfly-dev"

  compute_vpc                     = "dragonfly-dev-2-vpc"
  data_vpc                        = "dragonfly-data-vpc"

  arangodb_connector_plugin_name   = "kafka-connect-arangodb-1-2-0-dragonfly-2"
  arangodb_connector_logs_bucket   = "dragonfly-dev-kafka-connector-log-files"
  arangodb_connector_plugin_bucket = "dragonfly-dev-binaries-repository"
  arangodb_connector_plugin_jar    = "kafka-connect-arangodb-1.2.0-dragonfly-2.zip"
}
