locals {
  aws_account_name = "dragonfly-prod"
  aws_region       = "us-east-2"

  arango_connector_plugin_name      = "kafka-connect-arangodb"
  arango_connector_plugin_bucket    = "dragonfly-prod-binaries-repository"
  arangodb_connector_logs_bucket    = "dragonfly-prod-kafka-connector-log-files"
  arangodb_connector_plugin_version = "1.2.0"
  arangodb_connector_plugin_jar     = "kafka-connect-arangodb-${local.arangodb_connector_plugin_version}.jar"
}
