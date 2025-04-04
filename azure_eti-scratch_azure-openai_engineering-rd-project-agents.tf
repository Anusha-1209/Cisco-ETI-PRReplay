locals {
  name   = "engineering-rd-project-agents"
  region = "eastus"
  tags = {
    ApplicationName    = "engineering_rd"
    Component          = "test-agent"
    ResourceOwner      = "tiswanso"
    CiscoMailAlias     = "tiswanso@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "engineering-rd-project-agents" {
  name     = local.name
  location = local.region
}

resource "azurerm_cognitive_account" "engineering-rd-project-agents" {
  name                  = "${local.name}"
  custom_subdomain_name = "${local.name}"
  location              = azurerm_resource_group.engineering-rd-project-agents.location
  resource_group_name   = azurerm_resource_group.engineering-rd-project-agents.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.tags
}

resource "azurerm_cognitive_deployment" "engineering-rd-project-agents-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.engineering-rd-project-agents.id
  rai_policy_name      = "HIGH_INPUT_OUTPUT_FILTER"
  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-05-13"
  }

  sku {
    name = "GlobalStandard"
    capacity = 1000
  }
}