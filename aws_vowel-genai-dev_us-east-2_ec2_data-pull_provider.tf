
################################################################################
# Provider configuration
################################################################################

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

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${var.aws_account_name}/terraform_admin"
}
provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = var.region
  default_tags {
    tags = {
      ApplicationName    = local.name
      CiscoMailAlias     = var.cisco_mail_alias
      DataClassification = var.data_classification
      DataTaxonomy       = var.data_taxonomy
      Environment        = var.environment
      ResourceOwner      = var.resource_owner
    }
  }
}