provider "google" {
  version = "~> 3.53"
  project = "gcp-eticloudscratch-nprd-22453"
  region  = "us-west1"
  credentials = data.vault_generic_secret.gcp_infra_credential.data_json
}