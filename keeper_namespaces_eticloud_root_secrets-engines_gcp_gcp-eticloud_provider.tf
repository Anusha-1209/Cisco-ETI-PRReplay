provider "vault" {
  alias     = "eticloud"
  namespace = "eticloud"
}
# Pulling GCP credentials from Keeper
data "vault_generic_secret" "gcp_eticloud_infra_credentials" {
  provider = vault.eticloud
  path     = "secret/infra/gcp/eticloud"
}

# By setting the GCP provider credentials via the data source above, we control in which project the resources get created.
provider "google" {
  credentials = data.vault_generic_secret.gcp_eticloud_infra_credentials.data_json
}

provider "google-beta" {
  credentials = data.vault_generic_secret.gcp_eticloud_infra_credentials.data_json
}
