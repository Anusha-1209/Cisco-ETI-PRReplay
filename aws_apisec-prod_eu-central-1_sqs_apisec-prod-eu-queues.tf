terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-apisec-prod/sqs/eu-central-1/apisec-prod-eu-queues.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-central-1"
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "apisec-prod-eu-1-queues"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/apisec-prod/terraform_admin"
  provider = vault.eticloud
}
resource "aws_sqs_queue" "queue_3rd_party_api_scoring_inventory_results" {
  name = "topic-3rd-Party-API-Scoring-Inventory-Results-eu-central-1-apisec-backend"
}

resource "aws_sqs_queue" "queue_3rd_party_api_scoring" {
  name = "topic-3rd-Party-API-Scoring-eu-central-1-apisec-backend"
}

resource "aws_sqs_queue" "queue_cicd_job_results" {
  name = "topic-CICD-Job-Results-eu-central-1-apisec-backend"
}

resource "aws_sqs_queue" "queue_inventory_bad_design_topic" {
  name = "topic-InventoryBadDesignTopic_eu-central-1_apisec-backend"
}

resource "aws_sqs_queue" "queue_inventory_bad_implementation_topic" {
  name = "topic-InventoryBadImplementationTopic_eu-central-1_apisec-backend"
}

resource "aws_sqs_queue" "queue_inventory_sample_topic" {
  name = "topic-InventorySampleTopic_eu-central-1_apisec-backend"
}

resource "aws_sqs_queue" "queue_oas_analysis_results_inventory" {
  name = "topic-OAS-Analysis-Results-Inventory-eu-central-1-apisec-backend"
}

resource "aws_sqs_queue" "queue_oas_analysis" {
  name = "topic-OAS-Analysis-eu-central-1-apisec-backend"
}

resource "aws_sqs_queue" "queue_oas_drift_summary_topic" {
  name = "topic-OasDriftSummaryTopic_eu-central-1_apisec-backend"
}

resource "aws_sqs_queue" "queue_sensitive_data_sample_topic" {
  name = "topic-SensitiveDataSampleTopic_eu-central-1_apisec-backend"
}