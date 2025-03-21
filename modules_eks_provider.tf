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

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = var.region
  default_tags {
    tags = {
      ApplicationName    = var.application_name
      CiscoMailAlias     = var.cisco_mail_alias
      DataClassification = var.data_classification
      DataTaxonomy       = var.data_taxonomy
      Environment        = var.environment
      ResourceOwner      = var.resource_owner
    }
  }
}

provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = var.aws_infra_credential_path
  provider = vault.eticcprod
}
