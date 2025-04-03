terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/lightspin-dev/eu-west-1/eks/cspm-dev-euw1-1.tfstate"# UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.

  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.eks_aws_account_name}/terraform_admin"
}

provider "aws" {
  alias       = "eks"
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = local.region
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = local.name
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Restricted"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "Outshift SRE"
    }
  }
}