provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/cnapp-prod/terraform_admin"
}
terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/cnapp-prod/us-east-1/s3/rosey-logs.tfstate" # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.

  }
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-1"
}

module "s3" {
  source      = "git::https://github.com/cisco-eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket_name = "rosey-logs"
  # Continuous Security Buddy Tags.
  # For more information, see the CSB tagging Sharepoint page here:
  # https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Highly Confidential"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "rosey-logs"
  CSBResourceOwner      = "eti"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}

resource "aws_s3_bucket_lifecycle_configuration" "rosey-logs" {
  bucket = "rosey-logs"
  rule {
    id     = "TTL-policy"
    status = "Enabled"

    # expiration TBD
    expiration {
      days = 7
    }
  }
}
