terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"                                                       
    key    = "terraform-state/aws-eticloud/s3/us-east-1/phoenix-ui.tfstate" 
    region = "us-east-2"                                                                       
  }
}
provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
  alias     = "eticloud"
}
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/eticloud/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-1"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "outshift_ventures"
      Component          = "phoenix"
      CiscoMailAlias     = "outshift-phoenix@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "outshift-phoenix-admins"

      IntendedPublic = "False"
    }
  }
}

module "s3" {
  source                = "git::https://github.com/cisco-eti/sre-tf-module-aws-s3.git?ref=1.0.3"
  bucket_name           = "outshift-phoenix-ui"
  CSBApplicationName    = "outshift_ventures"
  CSBCiscoMailAlias     = "outshift-phoenix@cisco.com"
  CSBDataClassification = "Cisco Confidential"
  CSBDataTaxonomy       = "Cisco Operations Data"
  CSBEnvironment        = "NonProd"
  CSBResourceOwner      = "outshift-phoenix-admins"
}