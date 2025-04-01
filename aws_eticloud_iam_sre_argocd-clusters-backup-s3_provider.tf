terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 3.0"
    }
  }
}

data "vault_generic_secret" "aws_infra_credential" {
  path = replace("secret/data/eticcprod/infra/prod/aws", "/data/", "/")
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}