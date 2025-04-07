# This file was created by Outshift Platform Self-Service automation.
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"                                                      # We separate the different levels of development into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/outshift-common-dev/eu-central-1/s3/outshift-a3po-data.tfstate" # #note the path here. It should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                                      # Do not change without talking to the SRE team.
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
  region      = "eu-central-1"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "outshift_ventures"
      Component          = "a3po"
      CiscoMailAlias     = "outshift-a3po@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "a3po-admins"

      IntendedPublic = "False"

    }
  }
}

module "s3" {
  source                = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket_name           = "outshift-a3po-data"
  CSBApplicationName    = "outshift_ventures"
  CSBCiscoMailAlias     = "outshift-a3po@cisco.com"
  CSBDataClassification = "Cisco Confidential"
  CSBDataTaxonomy       = "Cisco Operations Data"
  CSBEnvironment        = "NonProd"
  CSBResourceOwner      = "a3po-admins"
}