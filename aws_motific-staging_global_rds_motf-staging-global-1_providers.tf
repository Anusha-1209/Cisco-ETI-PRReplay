provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "motf-staging-use2-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

provider "aws" {
  alias      = "secondary"
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-west-2"

  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "motf-staging-usw2"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
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
      version = "~> 4.3"
    }
  }
}
