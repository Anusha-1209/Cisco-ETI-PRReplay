provider "vault" {
  alias     = "synthetica"
  namespace = "eticloud/apps/synthetica"
}

provider "vault" {
  alias     = "eticcprod"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws-synthetica-dev-infra-credentials" {
    provider = vault.eticcprod
    path     = "secret/eticcprod/infra/synthetica-dev/aws"    
}

data "vault_generic_secret" "aws-eticloud-infra-credentials" {
    provider = vault.eticcprod
    path     = "secret/eticcprod/infra/prod/aws"
}

provider "aws" {
  alias       = "synthetica-dev"
  access_key  = data.vault_generic_secret.aws-synthetica-dev-infra-credentials.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws-synthetica-dev-infra-credentials.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}

provider "aws" {
  alias       = "eticloud"
  access_key  = data.vault_generic_secret.aws-eticloud-infra-credentials.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws-eticloud-infra-credentials.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}
