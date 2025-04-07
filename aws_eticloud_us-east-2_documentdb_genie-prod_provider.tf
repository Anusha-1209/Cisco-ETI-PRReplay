terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-eticloud/docdb/us-east-2/genie-prod-docdb.tfstate"
    region = "us-east-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.22.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.21.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3

  default_tags {
    tags = {
      ApplicationName    = "Genie"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud_eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "vault" {
  alias     = "genie"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/genie"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/prod/aws"
  provider = vault.eticloud_eticcprod
}

data "vault_generic_secret" "genie_docdb_credential" {
  path     = "secret/prod/genie-backend"
  provider = vault.genie
}