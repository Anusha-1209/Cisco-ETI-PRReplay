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