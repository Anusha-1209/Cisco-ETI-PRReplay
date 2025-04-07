# This provider allows access to the eticloud/eticcprod namespace in Keeper. Do not modify it without discussing with the SRE team.
provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the resources will be created.
# Must match the account in which the VPC was created.
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/ci/aws"
  provider = vault.eticcprod
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-sandbox"                               # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/s3/us-east-2/argocd-internal-backup.tfstate" #note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                               #do not change
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
  source      = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket_name = "argocd-internal-backup" # The name of the S3 bucket.  S3 bucket names are required to be globally unique across all of AWS.
  #Continuous Security Buddy Tags.
  #For more information, see the CSB tagging Sharepoint page here:
  #https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Restricted"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "ArgoCD"
  CSBResourceOwner      = "SRE"
  CSBCiscoMailAlias     = "eti-sre-admins@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}