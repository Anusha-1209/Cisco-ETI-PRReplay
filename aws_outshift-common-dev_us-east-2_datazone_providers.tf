provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "outshift_infrastructure"
      Component          = "platform_2025"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "outshift-team"
    }
  }
}
