# -------------------------------------------------------------------
# Terraform Configuration
# -------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod" # Set the correct bucket for the environment
    key    = "terraform-state/aws/outshift-common-prod/signalfx-integration.tfstate" # Set the AWS Account name in key
    region = "us-east-2"
  }
  required_providers {
    signalfx = {
      source = "splunk-terraform/signalfx"
    }
  }
}

# -------------------------------------------------------------------
# Local Variables
# -------------------------------------------------------------------
locals {
  account_name      = "outshift-common-prod" # Set AWS account name
  environment       = "prod"     # Set environment (prod, staging, dev)
  splunk_ingest_url = "https://ingest.us1.signalfx.com"
  default_tags = {
    ApplicationName  = "outshift_infrastructure"
    CiscoMailAlias   = "eti-sre-admins@cisco.com"
    Component        = "platform_2025"
    Environment      = "${local.environment}"
    Owner            = "ETI SRE Team"
    Project          = "Outshift Platform Observability"
    ResourceOwner    = "eti-sre-admin"
    TerraformManaged = "true"
  }
}

# -------------------------------------------------------------------
# AWS Account Credentials and Provider
# -------------------------------------------------------------------
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.account_name}/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3

  default_tags {
    tags = local.default_tags
  }
}

# -------------------------------------------------------------------
# Splunk Observability Credentials and Provider
# -------------------------------------------------------------------
provider "vault" {
  alias     = "eticloud_teamsecrets"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/teamsecrets"
}

data "vault_generic_secret" "generic_user_splunk_credential" {
  provider = vault.eticloud_teamsecrets
  path     = "secret/generic_users/eti-sre-cicd.gen"
}

provider "signalfx" {
  auth_token     = data.vault_generic_secret.generic_user_splunk_credential.data["outshift.signalfx.com_session_token"]
  api_url        = "https://api.us1.signalfx.com"
  custom_app_url = "https://outshift.signalfx.com"
}

# -------------------------------------------------------------------
# Module to Create AWS Integration in Splunk Observability
# -------------------------------------------------------------------
module "signalfx-aws-integration" {
  source                  = "../../../../modules/signalfx-aws-integration"
  aws_account_name        = local.account_name
  use_metric_streams_sync = true
  providers = {
    aws      = aws
    signalfx = signalfx
  }
}