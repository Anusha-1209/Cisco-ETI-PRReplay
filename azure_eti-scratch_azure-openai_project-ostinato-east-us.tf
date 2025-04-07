locals {
  project-ostinato = "project-ostinato"
  project-ostinato-tags = {
    ApplicationName    = "outshift_foundational_services"
    Component          = "ostinato"
    ResourceOwner      = "ostinato-admins"
    CiscoMailAlias     = "ostinato@cisco.com"
    DataClassification = "Cisco Highly Confidential"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "project-ostinato" {
  name     = local.project-ostinato
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "project-ostinato" {
  name                  = local.project-ostinato
  custom_subdomain_name = local.project-ostinato
  location              = azurerm_resource_group.project-ostinato.location
  resource_group_name   = azurerm_resource_group.project-ostinato.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.project-ostinato-tags
}

resource "azurerm_cognitive_deployment" "project-ostinato-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.project-ostinato.id
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

resource "azurerm_cognitive_deployment" "project-ostinato-gpt4o-mini" {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.project-ostinato.id
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