data "vault_generic_secret" "azure_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/azure/terraform_admin"
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

provider "vault" {
  alias     = "outshift-users"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/outshift-users"
}

provider "azurerm" {
  subscription_id = "a24f7eab-1920-42f7-9d33-9fb98a311c22"
  client_id       = data.vault_generic_secret.azure_infra_credential.data["appId"]
  client_secret   = data.vault_generic_secret.azure_infra_credential.data["password"]
  tenant_id       = data.vault_generic_secret.azure_infra_credential.data["tenant"]
  features {}
}