data "vault_generic_secret" "azure_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/azure/motific-staging/provider-access"
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "vault" {
  alias     = "motific"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/vowel"
}

provider "azurerm" {
  subscription_id = "c27de96e-9793-41d8-8ec7-7499674801bf"
  client_id       = data.vault_generic_secret.azure_infra_credential.data["appId"]
  client_secret   = data.vault_generic_secret.azure_infra_credential.data["password"]
  tenant_id       = data.vault_generic_secret.azure_infra_credential.data["tenant"]
  features {}
}