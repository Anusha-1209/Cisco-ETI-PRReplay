locals {
  prcoach-project-agents = "prcoach-project-agents"
  prcoach-project-agents-tags = {
    ApplicationName    = "prcoach"
    Component          = "prcoach"
    ResourceOwner      = "laszlon"
    CiscoMailAlias     = "laszlon@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "prcoach-project-agents" {
  name     = local.prcoach-project-agents
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "prcoach-project-agents" {
  name                  = "${local.prcoach-project-agents}"
  custom_subdomain_name = "${local.prcoach-project-agents}"
  location              = azurerm_resource_group.prcoach-project-agents.location
  resource_group_name   = azurerm_resource_group.prcoach-project-agents.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.prcoach-project-agents-tags
}

resource "azurerm_cognitive_deployment" "prcoach-project-agents-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.prcoach-project-agents.id
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

resource "azurerm_cognitive_deployment" "prcoach-project-agents-gpt4o-mini"  {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.prcoach-project-agents.id
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