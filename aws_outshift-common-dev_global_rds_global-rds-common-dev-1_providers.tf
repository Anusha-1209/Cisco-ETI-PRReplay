provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "aws" {
  alias       = "primary"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "global-rds-common-dev-1_primary"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
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
      ApplicationName    = "global-rds-common-dev-1_secondary"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}