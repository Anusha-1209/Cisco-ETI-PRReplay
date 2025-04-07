# This provider allows access to the eticloud/eticcprod namespace in Keeper. Do not modify it without discussing with the SRE team.
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the resources will be created.
# Must match the account in which the VPC was created.
data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/outshift-common-dev/terraform_admin"
}

terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/outshift-common-dev/us-east-2/s3/requests-failover-marvin-dev-use2-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.

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

module "s3" {
  source      = "git::https://github.com/cisco-eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket_name = "requests-failover-marvin-dev-use2-1" # The name of the S3 bucket.  S3 bucket names are required to be globally unique across all of AWS.
  #Continuous Security Buddy Tags.
  #For more information, see the CSB tagging Sharepoint page here:
  #https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Restricted"
  CSBEnvironment        = "NonProd"
  CSBApplicationName    = "Marvin"
  CSBResourceOwner      = "Outshift SRE"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}
