provider "vault" {
  alias     = "traiage"
  namespace = "eticloud/apps/traiage"
}

provider "vault" {
  alias     = "eticcprod"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws-genai-common-infra-credentials" {
    provider = vault.eticcprod
    path     = "secret/eticcprod/infra/genai-common/aws"    
}

data "vault_generic_secret" "aws-eticloud-infra-credentials" {
    provider = vault.eticcprod
    path     = "secret/eticcprod/infra/prod/aws"
}

provider "aws" {
  alias       = "genai-common"
  access_key  = data.vault_generic_secret.aws-genai-common-infra-credentials.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws-genai-common-infra-credentials.data["AWS_SECRET_ACCESS_KEY"]
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
