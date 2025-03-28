locals {
  name = "motific-dev"
  region = "eastus"
}

resource "azurerm_resource_group" "content-safety-rg" {
  name     = "${local.name}-content-safety-rg"
  location = local.region
}

resource "azurerm_cognitive_account" "content-safety" {
  name                = "${local.name}-content-safety"
  location            = azurerm_resource_group.content-safety-rg.location
  resource_group_name = azurerm_resource_group.content-safety-rg.name
  kind                = "ContentSafety"

  sku_name = "S0"
}

resource "vault_generic_secret" "content-safety" {
  path      = "secret/infra/azure/${local.name}/content-safety/keys"
  data_json = <<EOT
{
"endpoint": "${azurerm_cognitive_account.content-safety.endpoint}",
"primary_access_key": "${azurerm_cognitive_account.content-safety.primary_access_key}",
"secondary_access_key": "${azurerm_cognitive_account.content-safety.secondary_access_key}"
}
EOT
}