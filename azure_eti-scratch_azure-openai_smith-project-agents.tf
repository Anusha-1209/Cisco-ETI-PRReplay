locals {
  name   = "smith-project-agents"
  region = "eastus"
  tags = {
    ApplicationName    = "smith"
    CiscoMailAlias     = "eti-sre-admins@cisco.com"
    DataClassification = "Cisco Restricted"
    DataTaxonomy       = "Cisco Operations Data"
    Environment        = "NonProd"
    ResourceOwner      = "Outshift SRE"
  }
}

resource "azurerm_resource_group" "smith-project-agents" {
  name     = local.name
  location = local.region
}

resource "azurerm_cognitive_account" "smith-project-agents" {
  name                  = "${local.name}"
  custom_subdomain_name = "${local.name}"
  location              = azurerm_resource_group.smith-project-agents.location
  resource_group_name   = azurerm_resource_group.smith-project-agents.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.tags
}

resource "azurerm_cognitive_deployment" "smith-project-agents-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.smith-project-agents.id
  rai_policy_name      = "HIGH_INPUT_OUTPUT_FILTER"
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

# resource "azurerm_cognitive_deployment" "smith-project-agents-gpt4o-mini" {
#   name                 = "gpt-4o-mini"
#   cognitive_account_id = azurerm_cognitive_account.smith-project-agents.id
#   rai_policy_name      = "HIGH_INPUT_OUTPUT_FILTER"
#   model {
#     format  = "OpenAI"
#     name    = "gpt-4o-mini"
#     version = "2024-07-18"
#   }

#   sku {
#     name = "GlobalStandard"
#     capacity = 10
#   }
# }
