provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "eu-central-1"

  default_tags {
    tags = {
      ApplicationName    = "marvin-prod-euc1-1-msk"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "vault" {
  alias     = "apisec"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/apisec"
}
