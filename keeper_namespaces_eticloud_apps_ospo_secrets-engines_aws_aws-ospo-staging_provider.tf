provider "vault" {
  alias     = "ospo"
  namespace = "eticloud/apps/ospo"
}
provider "vault" {
  alias     = "eticloud"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/outshift-common-staging/terraform_admin"
}


# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  alias       = "ospo"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}

