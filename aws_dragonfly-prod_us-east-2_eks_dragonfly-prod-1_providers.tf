provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
  default_tags {
    tags = {
      ApplicationName    = "dragonfly-prod-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
  alias     = "eticloud"
}
