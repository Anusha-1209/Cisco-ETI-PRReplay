provider "vault" {
  alias     = "vowel"
  namespace = "eticloud/apps/vowel"
}

provider "vault" {
  alias     = "eticloud"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/motific-preview/terraform_admin"
}

# Infra AWS Provider
provider "aws" {
  alias       = "motific-preview"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}