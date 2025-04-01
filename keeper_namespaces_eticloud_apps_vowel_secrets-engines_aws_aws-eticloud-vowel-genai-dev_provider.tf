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
  path     = "secret/infra/aws/vowel-genai-dev/terraform_admin"
}

# Infra AWS Provider
provider "aws" {
  alias       = "vowel-genai-dev"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}