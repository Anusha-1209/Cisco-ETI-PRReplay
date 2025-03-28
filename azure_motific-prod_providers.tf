data "vault_generic_secret" "azure_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/azure/terraform_admin"
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "azurerm" {
  subscription_id = "c73d1cd9-08d8-4dc9-943c-cafe812dff5e"
  client_id       = data.vault_generic_secret.azure_infra_credential.data["appId"]
  client_secret   = data.vault_generic_secret.azure_infra_credential.data["password"]
  tenant_id       = data.vault_generic_secret.azure_infra_credential.data["tenant"]
  features {}
}