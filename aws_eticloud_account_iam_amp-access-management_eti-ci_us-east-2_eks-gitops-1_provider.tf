# eticloud, where the IAM roles and policies will live
provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]

  alias       = "destination"
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "amp-access-management"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

# other accounts, where the EKS clusters live
provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential_ci.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential_ci.data["AWS_SECRET_ACCESS_KEY"]

  alias  = "source"
  region = var.cluster_region
}

provider "vault" {
  alias     = "eticloud_eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/prod/aws"
  provider = vault.eticloud_eticcprod
}

data "vault_generic_secret" "aws_infra_credential_ci" {
  path     = "secret/eticcprod/infra/ci/aws"
  provider = vault.eticloud_eticcprod
}

provider "external" {}
