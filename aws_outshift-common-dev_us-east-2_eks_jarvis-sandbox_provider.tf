# This file was created by Outshift Platform Self-Service automation.
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.eks_aws_account}/terraform_admin"
}

provider "aws" {
  alias       = "eks"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "outshif_common_services"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Restricted"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}