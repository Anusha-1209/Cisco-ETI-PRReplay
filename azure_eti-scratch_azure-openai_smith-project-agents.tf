locals {
  smith-project-agents   = "smith-project-agents"
  smith-project-agents-tags = {
    ApplicationName    = "smith"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "Outshift SRE"
  }
}

resource "azurerm_resource_group" "smith-project-agents" {
  name     = local.smith-project-agents
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "smith-project-agents" {
  name                  = "${local.smith-project-agents}"
  custom_subdomain_name = "${local.smith-project-agents}"
  location              = azurerm_resource_group.smith-project-agents.location
  resource_group_name   = azurerm_resource_group.smith-project-agents.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.smith-project-agents-tags
}

resource "azurerm_cognitive_deployment" "smith-project-agents-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.smith-project-agents.id
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