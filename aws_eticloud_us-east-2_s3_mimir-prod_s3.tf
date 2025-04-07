provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path     = "secret/eticcprod/infra/prod/aws" # This path determines which account the resources are created in. The two options are 'scratch' and 'prod'.
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"                                     # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-Prod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/s3/us-east-2/mimir_prod_s3_buckets.tfstate" #note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                                  #do not change
  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2" #Set the region for the resources to be created.
}
# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
}

module "s3-eti-mimir-prod-blocks" {
  source      = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-s3.git?ref=1.0.1"
  bucket_name = "eti-mimir-prod-blocks" # The name of the S3 bucket.  S3 bucket names are required to be globally unique across all of AWS.
  #Continuous Security Buddy Tags.
  #For more information, see the CSB tagging Sharepoint page here:
  #https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Restricted"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "sre-mimir"
  CSBResourceOwner      = "eti"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}

module "s3-eti-mimir-prod-alertmanager" {
  source      = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-s3.git?ref=1.0.1"
  bucket_name = "eti-mimir-prod-alertmanager" # The name of the S3 bucket.  S3 bucket names are required to be globally unique across all of AWS.
  #Continuous Security Buddy Tags.
  #For more information, see the CSB tagging Sharepoint page here:
  #https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Restricted"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "sre-mimir"
  CSBResourceOwner      = "eti"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}

module "s3-eti-mimir-prod-ruler" {
  source      = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-s3.git?ref=1.0.1"
  bucket_name = "eti-mimir-prod-ruler" # The name of the S3 bucket.  S3 bucket names are required to be globally unique across all of AWS.
  #Continuous Security Buddy Tags.
  #For more information, see the CSB tagging Sharepoint page here:
  #https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Restricted"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "sre-mimir"
  CSBResourceOwner      = "eti"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}
