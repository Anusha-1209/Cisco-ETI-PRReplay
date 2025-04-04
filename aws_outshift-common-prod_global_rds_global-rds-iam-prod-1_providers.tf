provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "vault" {
  alias     = "teamsecrets"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/teamsecrets"
}

provider "aws" {
  alias       = "primary"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "outshift_foundational_services"
      Component          = "iam"
      ResourceOwner      = "eti-iam"
      CiscoMailAlias     = "eti-iam@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
    }
  }
}

provider "aws" {
  alias       = "secondary"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-west-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "global-rds-iam-prod-1_secondary"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

terraform {
  required_version = ">= 1.5.5"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.primary, aws.secondary]
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}