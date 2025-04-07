locals {
  agntcy-project = "agntcy"
  agntcy-project-tags = {
    ApplicationName    = "agntcy"
    Component          = "ioa"
    ResourceOwner      = "lumuscar"
    CiscoMailAlias     = "lumuscar@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
  }
}

resource "azurerm_resource_group" "agntcy-project" {
  name     = local.agntcy-project
  location = local.region_eastus
}

resource "azurerm_cognitive_account" "agntcy-project" {
  name                  = "${local.agntcy-project}"
  custom_subdomain_name = "${local.agntcy-project}"
  location              = azurerm_resource_group.agntcy-project.location
  resource_group_name   = azurerm_resource_group.agntcy-project.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.agntcy-project-tags
}

resource "azurerm_cognitive_deployment" "agntcy-project-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.agntcy-project.id
  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-11-20"
  }

  sku {
    name = "GlobalStandard"
    capacity = 1000
  }
}

resource "azurerm_cognitive_deployment" "agntcy-project-gpt4o-mini"  {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.agntcy-project.id
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