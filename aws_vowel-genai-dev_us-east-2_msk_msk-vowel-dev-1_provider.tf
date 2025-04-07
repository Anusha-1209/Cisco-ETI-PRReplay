provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"

  default_tags {
    tags = {
      ApplicationName    = "msk-vowel-dev-1"
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
  alias     = "eticloud_eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/vowel-genai-dev/aws"
  provider = vault.eticloud_eticcprod
}
