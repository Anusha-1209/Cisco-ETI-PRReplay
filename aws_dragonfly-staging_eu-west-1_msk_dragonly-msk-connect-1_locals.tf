locals {
  aws_account_name                 = "dragonfly-staging"

  compute_vpc                     = "dragonfly-compute-staging-1-vpc"
  data_vpc                        = "dragonfly-data-staging-1-vpc"

  arangodb_connector_plugin_name   = "kafka-connect-arangodb-1-2-0-dragonfly-4"
  arangodb_connector_logs_bucket   = "dragonfly-staging-kafka-connector-log-files"
  arangodb_connector_plugin_bucket = "dragonfly-staging-binaries-repository"
  arangodb_connector_plugin_jar    = "kafka-connect-arangodb-1.2.0-dragonfly-4.zip"

  arangodb_secret_name            = "thrill-arangodb"
}
