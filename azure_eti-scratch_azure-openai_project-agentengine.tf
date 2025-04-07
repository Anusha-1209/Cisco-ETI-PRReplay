locals {
  project-agentengine   = "project-agentengine"
  project-agentengine-tags = {
    ApplicationName    = "ActionEngine (LAM)"
    Component          = "Planner system"
    ResourceOwner      = "Julia Valenti"
    CiscoMailAlias     = "julvalen@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "project-agentengine" {
  name     = local.project-agentengine
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "project-agentengine" {
  name                  = "${local.project-agentengine}"
  custom_subdomain_name = "${local.project-agentengine}"
  location              = azurerm_resource_group.project-agentengine.location
  resource_group_name   = azurerm_resource_group.project-agentengine.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.project-agentengine-tags
}

resource "azurerm_cognitive_deployment" "project-agentengine-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.project-agentengine.id
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

resource "azurerm_cognitive_deployment" "project-agentengine-gpt4o-mini"  {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.project-agentengine.id
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