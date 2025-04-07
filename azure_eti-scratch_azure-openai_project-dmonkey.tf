locals {
  project-dmonkey   = "project-dmonkey"
  project-dmonkey-tags = {
    ApplicationName    = "dmonkey"
    Component          = "dmonkey"
    ResourceOwner      = "ai-team"
    CiscoMailAlias     = "sagupta7@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "project-dmonkey" {
  name     = local.project-dmonkey
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "project-dmonkey" {
  name                  = "${local.project-dmonkey}"
  custom_subdomain_name = "${local.project-dmonkey}"
  location              = azurerm_resource_group.project-dmonkey.location
  resource_group_name   = azurerm_resource_group.project-dmonkey.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.project-dmonkey-tags
}

resource "azurerm_cognitive_deployment" "project-dmonkey-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.project-dmonkey.id
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

resource "azurerm_cognitive_deployment" "project-dmonkey-gpt4o-mini"  {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.project-dmonkey.id
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