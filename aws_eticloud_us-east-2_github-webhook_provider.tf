# Atlantis has credentials to the eticloud AWS account. It uses those credentials to store and retrieve state information.
# `Path=` specifies the path to credentials in Keeper. The assumed namespace is eticloud/eticcprod.
# This data call is required for all accounts. The two current options are "scratch" (as below) and "prod".

provider "vault" {
    alias     = "eticcprod"
    address   = "https://keeper.cisco.com"
    namespace = "eticloud/eticcprod"
}

provider "vault" {
    alias     = "eticloud"
    address   = "https://keeper.cisco.com"
    namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path = "secret/eticcprod/infra/prod/aws"
}

# Describes the statefile and table in the eticloud aws account. Each Atlantis project should have it's own statefile (key)
terraform {
  backend "s3" {
    bucket        = "eticloud-tf-state-prod" # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key           = "terraform-state/github-webhook/us-east-2/github-webhook-prod.tfstate"  #note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region        = "us-east-2" #do not change
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.29.0"
    }
  }
}

# By setting the AWS provider credentials via the data source above, we control in which account and region the resources get created.
provider "aws" {
  region          = "us-east-2"
  access_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  max_retries = 3
}

provider "aws" {
  alias           = "virginia"
  region          = "us-east-1"
  access_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key      = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  max_retries = 3
}