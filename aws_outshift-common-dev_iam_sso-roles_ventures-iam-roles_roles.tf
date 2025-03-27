module "a3po_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "a3po"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "a3po"
    CiscoMailAlias  = "outshift-a3po@cisco.com"
    ResourceOwner   = "a3po-admins"
  }
}

module "action_engine_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "action-engine"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "action-engine"
    CiscoMailAlias  = "action-engine-team@cisco.com"
    ResourceOwner   = "action-engine-team"
  }
}

module "aether_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "aether"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "aether"
    CiscoMailAlias  = "outshift-aether@cisco.com"
    ResourceOwner   = "aether-admins"
  }
}

module "alfred_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "alfred"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "alfred"
    CiscoMailAlias  = "outshift-alfred@cisco.com"
    ResourceOwner   = "alfred-admins"
  }
}

module "aqua_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "aqua"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "aqua"
    CiscoMailAlias  = "aqua-team@cisco.com"
    ResourceOwner   = "outshift-aqua-dev"
  }
}

module "argus_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "argus"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "argus"
    CiscoMailAlias  = "outshift-argus-dev@cisco.com"
    ResourceOwner   = "outshift-argus-dev"
  }
}

module "cascade_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "cascade"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "cascade"
    CiscoMailAlias  = "chartsoo@cisco.com"
    ResourceOwner   = "cil-splunk"
  }
}

module "chef_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "chef"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "chef"
    CiscoMailAlias  = "outshift-chef-team@cisco.com"
    ResourceOwner   = "outshift-chef-team"
  }
}

module "ioa_identity_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "ioa-identity"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "ioa_identity"
    CiscoMailAlias  = "outshift-ioa-identity-team@cisco.com"
    ResourceOwner   = "outshift-ioa-identity-team"
  }
}

module "iridium_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "iridium"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "iridium"
    CiscoMailAlias  = "outshift-iridium@cisco.com"
    ResourceOwner   = "iridium-admins"
  }
}

module "marvin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "marvin"
  tags = {
    ApplicationName = "outshift_foundational_services"
    Component       = "marvin"
    CiscoMailAlias  = "marvin-outshift@cisco.com"
    ResourceOwner   = "marvin-outshift"
  }
}

module "ostinato_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "ostinato"
  tags = {
    ApplicationName = "outshift_foundational_services"
    Component       = "ostinato"
    CiscoMailAlias  = "ostinato-team-mailer@cisco.com"
    Environment     = "NonProd"
    ResourceOwner   = "ostinato-dev-team"
  }
}

module "eti_website_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "eti-website"
  tags = {
    ApplicationName = "outshift_marketing"
    Component       = "outshift_websites"
    CiscoMailAlias  = "eti-websites@cisco.com"
    ResourceOwner   = "eti-website-admins"
  }
}

module "poirot_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "poirot"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "poirot"
    CiscoMailAlias  = "outshift-poirot-admins@cisco.com"
    ResourceOwner   = "outshift-poirot-admins"
  }
}

module "phoenix_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "phoenix"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "phoenix"
    CiscoMailAlias  = "outshift-phoenix@cisco.com"
    ResourceOwner   = "outshift-phoenix-admins"
  }
}

module "ragv2_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "ragv2"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "ragv2"
    CiscoMailAlias  = "ragv2@cisco.com"
    ResourceOwner   = "ragv2-team"
  }
}