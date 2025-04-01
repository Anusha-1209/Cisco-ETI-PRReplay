provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.account_name}/terraform_admin"
}

locals {
  bucket_names = ["rosey-logs-us", "rosey-logs-eu"]
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
  alias      = "us"
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
}

provider "aws" {
  alias      = "eu"
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "eu-central-1"
}


# https://github.com/hashicorp/terraform/issues/24476
# have to repeat module call due to using 2 providers for each AWS region
module "s3" {
  providers = {
    aws = aws.us
  }
  source      = "git::https://github.com/cisco-eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket_name = "rosey-logs-us"
  # Continuous Security Buddy Tags.
  # For more information, see the CSB tagging Sharepoint page here:
  # https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Highly Confidential"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "rosey-logs-us"
  CSBResourceOwner      = "eti"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}

module "s3" {
  providers = {
    aws = aws.eu
  }
  source      = "git::https://github.com/cisco-eti/sre-tf-module-aws-s3.git?ref=1.0.2"
  bucket_name = "rosey-logs-eu"
  # Continuous Security Buddy Tags.
  # For more information, see the CSB tagging Sharepoint page here:
  # https://cisco.sharepoint.com/Sites/CSB/SitePages/Security%20Tagging%20and%20Audit%20in%20AWS.aspx
  CSBDataClassification = "Cisco Highly Confidential"
  CSBEnvironment        = "Prod"
  CSBApplicationName    = "rosey-logs-eu"
  CSBResourceOwner      = "eti"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}

resource "aws_s3_bucket_lifecycle_configuration" "rosey-logs" {
  for_each = toset(bucket_names)
  bucket   = each.key
  rule {
    id     = "TTL-policy"
    status = "Enabled"

    # expiration TBD
    expiration {
      days = 7
    }
  }
}
