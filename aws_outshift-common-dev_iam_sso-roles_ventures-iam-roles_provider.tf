provider "vault" {
  address   = "https://keeper.cisco.com" # DON'T CHANGE THIS VALUE
  namespace = "eticloud"                 # DON'T CHANGE THIS VALUE
}

locals {
  account_name = "outshift-common-dev"
}

data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/infra/aws/${local.account_name}/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]     # DON'T CHANGE THIS VALUE
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"] # DON'T CHANGE THIS VALUE
  region      = "us-east-2"                                                                 
  max_retries = 3
}
