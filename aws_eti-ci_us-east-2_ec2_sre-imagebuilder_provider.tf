terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
  max_retries = 3
}

# DNS AWS provider
provider "aws" {
  alias = "dns"
  access_key = data.vault_generic_secret.aws_dns_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_dns_credential.data["AWS_SECRET_ACCESS_KEY"]
  region = data.vault_generic_secret.aws_dns_credential.data["AWS_DEFAULT_REGION"]
  max_retries = 3
 }