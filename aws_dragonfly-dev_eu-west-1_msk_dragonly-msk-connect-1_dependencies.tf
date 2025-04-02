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
