terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 3.0"
    }
  }
}
provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}
data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/infra/aws/sscs-dev/terraform_admin"
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
}
