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
    bucket         = "eticloud-tf-state-prod"                                 
    key            = "terraform-state/aws-eticloud/s3/us-east-1/cisco-eti-argocd-bootstrap-backup.tfstate"
    region         = "us-east-2"
    dynamodb_table = "eticloud-tf-locks"
    encrypt        = true                                                 
  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-1" #Set the region for the resources to be created.
}
# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
}

module "cisco-eti-argocd-bootstrap-backup-blocks" {
  source      = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-s3.git?ref=1.0.1"
  bucket_name = "cisco-eti-argocd-bootstrap-backup" # The name of the S3 bucket.  S3 bucket names are required to be globally unique across all of AWS.
  #Continuous Security Buddy Tags.
  #For more information, see the CSB tagging Sharepoint page here:
  #https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Restricted"
  CSBEnvironment        = "NonProd"
  CSBApplicationName    = "sre-argocd-bootstrap"
  CSBResourceOwner      = "eti"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}
