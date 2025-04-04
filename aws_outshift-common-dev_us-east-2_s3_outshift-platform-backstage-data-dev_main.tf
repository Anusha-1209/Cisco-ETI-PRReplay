# This file was created by Outshift Platform Self-Service automation.
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"                                                                     # We separate the different levels of development into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/outshift-common-dev/us-east-2/s3/outshift-platform-backstage-data-dev.tfstate" # #note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                                                     # Do not change without talking to the SRE team.
  }
}
provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
  alias     = "eticloud"
}
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/outshift-common-dev/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "ETI SRE Platform"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Restricted"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "subbaksh@cisco.com"

      IntendedPublic = "False"

    }
  }
}

module "s3" {
  source                = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket_name           = "outshift-platform-backstage-data-dev"
  CSBApplicationName    = "ETI SRE Platform"
  CSBCiscoMailAlias     = "eti-sre-admins@cisco.com"
  CSBDataClassification = "Cisco Restricted"
  CSBDataTaxonomy       = "Cisco Operations Data"
  CSBEnvironment        = "NonProd"
  CSBResourceOwner      = "subbaksh@cisco.com"
}