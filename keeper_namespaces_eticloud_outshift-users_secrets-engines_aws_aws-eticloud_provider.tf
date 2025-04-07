provider "vault" {
  alias     = "eticloud"
  namespace = "eticloud"
}

provider "vault" {
  alias     = "outshift-users"
  namespace = "eticloud/outshift-users"
}

data "vault_generic_secret" "aws_infra_credential" {
  path      = "secret/infra/aws/eticloud/terraform_admin"
}

# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}