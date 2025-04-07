# -------------------------------------------------------------------
# Terraform Configuration
# -------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/signalfx/integration-pagerduty-openg.tfstate"
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
  splunk_ingest_url = "https://ingest.us1.signalfx.com"
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
