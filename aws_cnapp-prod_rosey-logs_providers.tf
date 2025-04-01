terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.us, aws.eu]
    }
  }
}

provider "aws" {
  alias       = "us"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "Rosey logs"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Highly Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "aws" {
  alias       = "eu"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-central-1"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "Rosey logs"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Highly Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/infra/aws/${local.account_name}/terraform_admin"
}
