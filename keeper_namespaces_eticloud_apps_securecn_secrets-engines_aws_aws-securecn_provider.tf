provider "vault" {
  alias     = "securecn"
  namespace = "eticloud/apps/securecn"
}

provider "vault" {
  alias     = "eticcprod"
  namespace = "eticloud/eticcprod"
}

# Pulling AWS credentials from Keeper

data "vault_generic_secret" "aws-securecn-infra-credentials" {
    provider = vault.eticcprod
    path     = "secret/eticcprod/infra/securecn-dev/aws"    
}

data "vault_generic_secret" "aws-eticloud-infra-credentials" {
    provider = vault.eticcprod
    path     = "secret/eticcprod/infra/prod/aws"
}

# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  alias       = "securecn"
  access_key  = data.vault_generic_secret.aws-securecn-infra-credentials.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws-securecn-infra-credentials.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}

# Providers without an alias becomes the _default_ for resources that do not specify a provider
provider "aws" {
  alias       = "eticloud"
  access_key  = data.vault_generic_secret.aws-eticloud-infra-credentials.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws-eticloud-infra-credentials.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}
