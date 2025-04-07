locals {
  project-ostinato-eus2   = "project-ostinato-eus2"
}

resource "azurerm_resource_group" "project-ostinato-eus2" {
  name     = local.project-ostinato-eus2
  location = local.region_eastus2
}

resource "azurerm_cognitive_account" "project-ostinato-eus2" {
  name                  = "${local.project-ostinato-eus2}"
  custom_subdomain_name = "${local.project-ostinato-eus2}"
  location              = azurerm_resource_group.project-ostinato-eus2.location
  resource_group_name   = azurerm_resource_group.project-ostinato-eus2.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  tags                  = local.project-ostinato-tags
}

resource "azurerm_cognitive_deployment" "project-ostinato-eus2-gpt4o" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.project-ostinato-eus2.id
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

resource "azurerm_cognitive_deployment" "project-ostinato-eus2-gpt4o-mini"  {
  name                 = "gpt-4o-mini"
  cognitive_account_id = azurerm_cognitive_account.project-ostinato-eus2.id
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

resource "azurerm_cognitive_deployment" "project-ostinato-eus2-o1"  {
  name                 = "o1"
  cognitive_account_id = azurerm_cognitive_account.project-ostinato-eus2.id
  model {
    format  = "OpenAI"
    name    = "o1"
    version = "2024-12-17"
  }

  sku {
    name = "GlobalStandard"
    capacity = 1000
  }
}

resource "azurerm_cognitive_deployment" "project-ostinato-eus2-o1-mini"  {
  name                 = "o1-mini"
  cognitive_account_id = azurerm_cognitive_account.project-ostinato-eus2.id
  model {
    format  = "OpenAI"
    name    = "o1-mini"
    version = "2024-09-12"
  }

  sku {
    name = "GlobalStandard"
    capacity = 1000
  }
}

resource "azurerm_cognitive_deployment" "project-ostinato-eus2-o3-mini"  {
  name                 = "o3-mini"
  cognitive_account_id = azurerm_cognitive_account.project-ostinato-eus2.id
  model {
    format  = "OpenAI"
    name    = "o3-mini"
    version = "2025-01-31"
  }

  sku {
    name = "GlobalStandard"
    capacity = 1000
  }
}