data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
  provider = vault.eticloud
}

// account information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

// Arangodb secrets from vault
data "vault_generic_secret" "arangodb_secrets" {
  path     = "dev/thrill-arangodb"
  provider = vault.dragonfly
}

// kafka cluster information
data "aws_msk_cluster" "dragonfly_msk_1" {
  cluster_name = "dragonfly-msk-1"
}

// execution role for msk connect
data "aws_iam_role" "msk_connect_execution_role" {
  name = "dragonfly-msk-connect-execution-role"
}

// bucket containing the custom plugin jar
data "aws_s3_bucket" "mskconnect_custom_plugin_bucket" {
  bucket = local.arangodb_connector_plugin_bucket
}

// Jar object in the bucket
data "aws_s3_object" "mskconnect_custom_plugin_jar" {
  bucket = data.aws_s3_bucket.mskconnect_custom_plugin_bucket.bucket
  key    = local.arangodb_connector_plugin_jar
}
