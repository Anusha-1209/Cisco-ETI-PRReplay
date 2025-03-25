provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"

  default_tags {
    tags = {
      ApplicationName    = "motf-preview-use2-1-msk"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

provider "vault" {
  alias     = "vowel"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/vowel"
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/motific-preview/terraform_admin"
  provider = vault.eticloud
}