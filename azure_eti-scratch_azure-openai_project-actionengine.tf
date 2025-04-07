locals {
  project-actionengine   = "project-actionengine"
  project-actionengine-tags = {
    ApplicationName    = "ActionEngine (LAM)"
    Component          = "Planner system"
    ResourceOwner      = "Julia Valenti"
    CiscoMailAlias     = "julvalen@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "project-actionengine" {
  name     = local.project-actionengine
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "project-actionengine" {
  name                  = "${local.project-actionengine}"
  custom_subdomain_name = "${local.project-actionengine}"
  location              = azurerm_resource_group.project-actionengine.location
  resource_group_name   = azurerm_resource_group.project-actionengine.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.project-actionengine-tags
}

resource "azurerm_cognitive_deployment" "project-actionengine-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.project-actionengine.id
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

resource "azurerm_cognitive_deployment" "project-actionengine-gpt4o-mini"  {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.project-actionengine.id
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