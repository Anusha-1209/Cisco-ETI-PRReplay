locals {
  engineering-rd-mini-project-agents   = "engineering-rd-mini-project-agents"
  engineering-rd-mini-project-agents-tags = {
    ApplicationName    = "engineering_rd"
    Component          = "test-agent"
    ResourceOwner      = "gbourgin"
    CiscoMailAlias     = "gbourgin@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "engineering-rd-mini-project-agents" {
  name     = local.engineering-rd-mini-project-agents
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "engineering-rd-mini-project-agents" {
  name                  = "${local.engineering-rd-mini-project-agents}"
  custom_subdomain_name = "${local.engineering-rd-mini-project-agents}"
  location              = azurerm_resource_group.engineering-rd-mini-project-agents.location
  resource_group_name   = azurerm_resource_group.engineering-rd-mini-project-agents.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.engineering-rd-mini-project-agents-tags
}

resource "azurerm_cognitive_deployment" "engineering-rd-mini-project-agents-gpt4o" {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.engineering-rd-mini-project-agents.id
  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-07-18"
  }

  sku {
    name = "GlobalStandard"
    capacity = 1000
  }
}