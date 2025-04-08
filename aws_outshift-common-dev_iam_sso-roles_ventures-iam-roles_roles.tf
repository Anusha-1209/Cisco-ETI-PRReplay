module "a3po_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "a3po-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "a3po"
    CiscoMailAlias  = "outshift-a3po@cisco.com"
    ResourceOwner   = "a3po-admins"
  }
}

module "action_engine_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "action-engine-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "action-engine"
    CiscoMailAlias  = "action-engine-team@cisco.com"
    ResourceOwner   = "action-engine-team"
  }
}

module "aether_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "aether-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "aether"
    CiscoMailAlias  = "outshift-aether@cisco.com"
    ResourceOwner   = "aether-admins"
  }
}

module "alfred_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "alfred-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "alfred"
    CiscoMailAlias  = "outshift-alfred@cisco.com"
    ResourceOwner   = "alfred-admins"
  }
}

module "aqua_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "aqua-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "aqua"
    CiscoMailAlias  = "aqua-team@cisco.com"
    ResourceOwner   = "outshift-aqua-dev"
  }
}

module "argus_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "argus-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "argus"
    CiscoMailAlias  = "outshift-argus-dev@cisco.com"
    ResourceOwner   = "outshift-argus-dev"
  }
}

module "cascade_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "cascade-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "cascade"
    CiscoMailAlias  = "chartsoo@cisco.com"
    ResourceOwner   = "cil-splunk"
  }
}

module "chef_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "chef-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "chef"
    CiscoMailAlias  = "outshift-chef-team@cisco.com"
    ResourceOwner   = "outshift-chef-team"
  }
}

module "chef_devops_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "chef-devops"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "chef"
    CiscoMailAlias  = "outshift-chef-team@cisco.com"
    ResourceOwner   = "outshift-chef-team"
  }
}

module "ioa_identity_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "ioa-identity-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "ioa_identity"
    CiscoMailAlias  = "outshift-ioa-identity-team@cisco.com"
    ResourceOwner   = "outshift-ioa-identity-team"
  }
}

module "iridium_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "iridium-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "iridium"
    CiscoMailAlias  = "outshift-iridium@cisco.com"
    ResourceOwner   = "iridium-admins"
  }
}

module "marvin_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "marvin-admin"
  tags = {
    ApplicationName = "outshift_foundational_services"
    Component       = "marvin"
    CiscoMailAlias  = "marvin-outshift@cisco.com"
    ResourceOwner   = "marvin-outshift"
  }
}

module "ostinato_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "ostinato-admin"
  tags = {
    ApplicationName = "outshift_foundational_services"
    Component       = "ostinato"
    CiscoMailAlias  = "ostinato-team-mailer@cisco.com"
    Environment     = "NonProd"
    ResourceOwner   = "ostinato-dev-team"
  }
}

module "eti_website_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "eti-website-admin"
  tags = {
    ApplicationName = "outshift_marketing"
    Component       = "outshift_websites"
    CiscoMailAlias  = "eti-websites@cisco.com"
    ResourceOwner   = "eti-website-admins"
  }
}

module "poirot_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "poirot-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "poirot"
    CiscoMailAlias  = "outshift-poirot-admins@cisco.com"
    ResourceOwner   = "outshift-poirot-admins"
  }
}

module "phoenix_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "phoenix-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "phoenix"
    CiscoMailAlias  = "outshift-phoenix@cisco.com"
    ResourceOwner   = "outshift-phoenix-admins"
  }
}

module "ragv2_admin_role" {
  source    = "git::https://github.com/cisco-eti/platform-terraform-infra.git//modules/sso-roles"
  role_name = "ragv2-admin"
  tags = {
    ApplicationName = "outshift_ventures"
    Component       = "ragv2"
    CiscoMailAlias  = "ragv2@cisco.com"
    ResourceOwner   = "ragv2-team"
  }
}