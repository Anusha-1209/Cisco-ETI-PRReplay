locals {
  engineering-rd-project-agents = "engineering-rd-project-agents"
  engineering-rd-project-agents-tags = {
    ApplicationName    = "outshift_ventures"
    Component          = "engineering_rd"
    ResourceOwner      = "tiswanso"
    CiscoMailAlias     = "tiswanso@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "engineering-rd-project-agents" {
  name     = local.engineering-rd-project-agents
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "engineering-rd-project-agents" {
  name                  = local.engineering-rd-project-agents
  custom_subdomain_name = local.engineering-rd-project-agents
  location              = azurerm_resource_group.engineering-rd-project-agents.location
  resource_group_name   = azurerm_resource_group.engineering-rd-project-agents.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.engineering-rd-project-agents-tags
}

resource "azurerm_cognitive_deployment" "engineering-rd-project-agents-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.engineering-rd-project-agents.id
  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-05-13"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 1000
  }
}

resource "azurerm_cognitive_deployment" "engineering-rd-project-agents-gpt4o-mini" {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.engineering-rd-project-agents.id
  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-07-18"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 1000
  }
}