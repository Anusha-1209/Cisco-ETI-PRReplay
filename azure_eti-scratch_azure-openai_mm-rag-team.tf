locals {
  mm-rag-team   = "mm-rag-team"
  region = "eastus"
  ai-team-tags = {
    ApplicationName    = "ai-team"
    ComponentName      = "mm-rag-team"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "Maciej Jerzy Filipowicz"
  }
}

resource "azurerm_resource_group" "mm-rag-team" {
  name     = local.mm-rag-team
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "mm-rag-team" {
  name                  = "${local.mm-rag-team}"
  custom_subdomain_name = "${local.mm-rag-team}"
  location              = azurerm_resource_group.mm-rag-team.location
  resource_group_name   = azurerm_resource_group.mm-rag-team.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.ai-team-tags
}

resource "azurerm_cognitive_deployment" "mm-rag-team-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.mm-rag-team.id
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