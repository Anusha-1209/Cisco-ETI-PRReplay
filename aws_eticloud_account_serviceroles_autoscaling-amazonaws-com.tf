terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-nonprod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/eticloud/servicerole/autoscaling-amazonaws-com.tfstate"
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider    = vault.eticloud
  path        = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = local.region
}

locals {
  region            = "us-east-2"
  aws_account_name  = "eticloud"
}

resource "aws_iam_service_linked_role" "AWSServiceRoleForAutoScaling" {
  aws_service_name = "autoscaling.amazonaws.com"
}