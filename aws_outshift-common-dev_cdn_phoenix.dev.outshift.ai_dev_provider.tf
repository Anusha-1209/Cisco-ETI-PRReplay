terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.5"
    }
  }
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/infra/aws/${local.aws_account}/terraform_admin"
}

data "vault_generic_secret" "aws_infra_credential_route53" {
  path = "secret/infra/aws/${local.route53_account}/terraform_admin"
}
provider "aws" {
  alias       = "us-east-2"
  region      = "us-east-2"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  max_retries = 3

  default_tags {
    tags = {
      ApplicationName    = "outshift_ventures"
      Component          = "phoenix"
      CiscoMailAlias     = "outshift-phoenix@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "outshift-phoenix-admins"
    }
  }
}

provider "aws" {
  alias       = "us-east-1"
  region      = "us-east-1"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  max_retries = 3

  default_tags {
    tags = {
      ApplicationName    = "outshift_ventures"
      Component          = "phoenix"
      CiscoMailAlias     = "outshift-phoenix@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "outshift-phoenix-admins"
    }
  }
}

provider "aws" {
  alias       = "route53"
  region      = "us-east-1"
  access_key  = data.vault_generic_secret.aws_infra_credential_route53.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential_route53.data["AWS_SECRET_ACCESS_KEY"]
  max_retries = 3

  default_tags {
    tags = {
      ApplicationName    = "outshift_ventures"
      Component          = "phoenix"
      CiscoMailAlias     = "outshift-phoenix@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "outshift-phoenix-admins"
    }
  }
}