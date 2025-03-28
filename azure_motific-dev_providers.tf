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

provider "azurerm" {
  subscription_id = "2c2e2b9a-17a9-4252-a3ef-4b4d550a3597"
  client_id       = data.vault_generic_secret.azure_infra_credential.data["appId"]
  client_secret   = data.vault_generic_secret.azure_infra_credential.data["password"]
  tenant_id       = data.vault_generic_secret.azure_infra_credential.data["tenant"]
  features {}
}