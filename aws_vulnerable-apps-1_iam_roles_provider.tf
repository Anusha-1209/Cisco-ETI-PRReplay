provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-west-1"
  default_tags {
    tags = {
        ApplicationName    = "vae-iam"
        CiscoMailAlias     = "eti-sre-admins@cisco.com"
        DataClassification = "Cisco Confidential"
        DataTaxonomy       = "Cisco Operations Data"
        EnvironmentName    = "NonProd"
        ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/eticcprod/infra/vulnerable-apps-1/aws"
  provider = vault.eticloud
}
