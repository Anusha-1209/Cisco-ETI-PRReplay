provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path     = "secret/eticcprod/infra/ci/aws" # should be migrated to secret/infra/aws/eti-ci/terraform_admin in the eticloud namespace
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/ec2/us-east-2/gha-self-hosted-runners.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.region
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "gha-self-hosted-runners-cloud-agents"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}
