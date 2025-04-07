locals {
  phoenix-project-agents = "phoenix-project-agents"
  phoenix-project-agents-tags = {
    ApplicationName    = "phoenix"
    Component          = "oap"
    ResourceOwner      = "lumuscar"
    CiscoMailAlias     = "lumuscar@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "phoenix-project-agents" {
  name     = local.phoenix-project-agents
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "phoenix-project-agents" {
  name                  = "${local.phoenix-project-agents}"
  custom_subdomain_name = "${local.phoenix-project-agents}"
  location              = azurerm_resource_group.phoenix-project-agents.location
  resource_group_name   = azurerm_resource_group.phoenix-project-agents.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.phoenix-project-agents-tags
}

resource "azurerm_cognitive_deployment" "phoenix-project-agents-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.phoenix-project-agents.id
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

resource "azurerm_cognitive_deployment" "phoenix-project-agents-gpt4o-mini"  {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.phoenix-project-agents.id
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