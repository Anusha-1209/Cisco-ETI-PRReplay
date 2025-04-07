locals {
  ragv2-project-agents   = "ragv2-project-agents"
  ragv2-project-agents-tags = {
    ApplicationName    = "outshift_foundational_services"
    Component          = "ragv2"
    ResourceOwner      = "sushroff"
    CiscoMailAlias     = "sushroff@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "ragv2-project-agents" {
  name     = local.ragv2-project-agents
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "ragv2-project-agents" {
  name                  = "${local.ragv2-project-agents}"
  custom_subdomain_name = "${local.ragv2-project-agents}"
  location              = azurerm_resource_group.ragv2-project-agents.location
  resource_group_name   = azurerm_resource_group.ragv2-project-agents.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.ragv2-project-agents-tags
}

resource "azurerm_cognitive_deployment" "ragv2-project-agents-gpt-4o-mini" {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.ragv2-project-agents.id
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