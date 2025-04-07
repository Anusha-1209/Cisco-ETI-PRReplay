terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0, >= 3.38.0" # 3.38.0 adds tag propagation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/resource-tagging#propagating-tags-to-all-resources
    }
  }
}

data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/prod/aws"
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

  default_tags {
    tags = {
      CiscoMailAlias  = "eti-sre_at_cisco_dot_com"
      ApplicationName = "ETI Identity"
      Environment     = "NonProd"
      ResourceOwner   = "ETI SRE"
    }
  }
}
