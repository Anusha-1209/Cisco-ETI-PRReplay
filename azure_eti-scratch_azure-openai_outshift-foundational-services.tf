locals {
  name   = "outshift-foundational-services-project-agents"
  region = "eastus"
  tags = {
    ApplicationName    = "outshift_foundational_services"
    Component          = "ragv2"
    ResourceOwner      = "sushroff"
    CiscoMailAlias     = "sushroff@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "outshift-foundational-services-project-agents" {
  name     = local.name
  location = local.region
}

resource "azurerm_cognitive_account" "outshift-foundational-services-project-agents" {
  name                  = "${local.name}"
  custom_subdomain_name = "${local.name}"
  location              = azurerm_resource_group.outshift-foundational-services-project-agents.location
  resource_group_name   = azurerm_resource_group.outshift-foundational-services-project-agents.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.tags
}

resource "azurerm_cognitive_deployment" "outshift-foundational-services-project-agents-gpt4o-mini" {
  name                 = "gpt-4o-mini "
  cognitive_account_id = azurerm_cognitive_account.outshift-foundational-services-project-agents.id
  rai_policy_name      = "HIGH_INPUT_OUTPUT_FILTER"
  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-05-13"
  }

  sku {
    name = "GlobalStandard"
    capacity = 1000
  }
}