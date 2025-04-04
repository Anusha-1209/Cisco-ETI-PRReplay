provider "vault" {
  alias     = "eticloud"
  namespace = "eticloud"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/teamsecrets"
  alias     = "teamsecrets"
}

variable "oidc_client_id" {
  type    = string
  default = "DII9TO378NM0ZW02ABST" # <-- requires updating
}

variable "venture_name" {
  type    = string
  default = "eticloud" # <-- requires updating
}

# OIDC Credentials
data "vault_generic_secret" "oidc_credential" {
  provider = vault.teamsecrets
  path     = "secret/cisco_sso_auth_clients/vault_oidc_creds"
}

resource "vault_jwt_auth_backend" "oidc" {
  provider            = vault.eticloud
  type                = "oidc"
  path                = "oidc"
  oidc_client_id      = var.oidc_client_id
  default_role        = "vault_admin"
  oidc_client_secret  = data.vault_generic_secret.oidc_credential.data["client_secret"]
  oidc_discovery_url  = "https://sso-dbbfec7f.sso.duosecurity.com/oidc/${var.oidc_client_id}"
}

resource "vault_policy" "vault-admin" {
  name   = "vault-admin"
  policy = <<EOT
path "*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}
# List, create, update, and delete key/value secrets
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}
# List existing policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}
path "sys/policy"
{
  capabilities = ["list", "read"]
}
# Create and manage  policies
path "sys/policies/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "sys/policy/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Manage secret engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List existing secret engines.
path "sys/mounts"
{
  capabilities = ["read"]
}
# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}
path "aws/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Manage PKI secret engines
path "k8s/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}

resource "vault_policy" "backstage-developer" {
  name   = "backstage-developer"
  policy = <<EOT
path "secret/project/backstage/dev/*"
{
  capabilities = ["create", "read", "update", "list"]
}
path "secret/data/project/backstage/dev/*"
{
  capabilities = ["create", "read", "update", "list"]
}
path "secret/*"
{
  capabilities = ["list"]
}

EOT
}

resource "vault_policy" "groups_automation_devs" {
  name   = "groups_automation_devs"
  policy = <<EOT
# Common secrets
path "secret/data/common/groups-automation/*" {
  capabilities = ["update","delete","create","read", "list"]
}
path "secret/common/groups-automation/*" {
  capabilities = ["update","delete","create","read", "list"]
}

EOT
}

resource "vault_jwt_auth_backend_role" "vault_admin" {
  depends_on                   = [ vault_policy.vault-admin ]
  provider                     = vault.eticloud
  role_name                    = "vault_admin"
  role_type                    = "oidc"
  backend                      = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris        = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://east.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "http://localhost:8250/oidc/callback"]
  bound_audiences              = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=eticloud-keeper-vault-admin,OU=Cisco Groups,DC=cisco,DC=com"
  }
  disable_bound_claims_parsing = true
  bound_claims_type            = "string"
  claim_mappings = {
    email       = "email",
    family_name = "family_name",
    given_name  = "given_name",
    sub         = "sub"
  }
  groups_claim                 = "memberof"
  oidc_scopes                  = ["profile", "email", "openid"]
  user_claim                   = "sub"
  token_policies               = ["vault-admin"]

}

resource "vault_jwt_auth_backend_role" "backstage-developer" {
  depends_on                   = [ vault_policy.backstage-developer ]
  provider                     = vault.eticloud
  role_name                    = "backstage-developer"
  role_type                    = "oidc"
  backend                      = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris        = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://east.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "http://localhost:8250/oidc/callback"]
  bound_audiences              = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=outshift-backstage-developers,OU=Cisco Groups,DC=cisco,DC=com"
  }
  disable_bound_claims_parsing = true
  bound_claims_type            = "string"
  claim_mappings = {
    email       = "email",
    family_name = "family_name",
    given_name  = "given_name",
    sub         = "sub"
  }
  groups_claim                 = "memberof"
  oidc_scopes                  = ["profile", "email", "openid"]
  user_claim                   = "sub"
  token_policies               = [vault_policy.backstage-developer.name]

}

resource "vault_jwt_auth_backend_role" "groups_automation_devs" {
  depends_on                   = [ vault_policy.groups_automation_devs ]
  provider                     = vault.eticloud
  role_name                    = "groups_automation_devs"
  role_type                    = "oidc"
  backend                      = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris        = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://east.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "http://localhost:8250/oidc/callback"]
  bound_audiences              = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=groups-automation-devs,OU=Cisco Groups,DC=cisco,DC=com"
  }
  disable_bound_claims_parsing = true
  bound_claims_type            = "string"
  claim_mappings = {
    email       = "email",
    family_name = "family_name",
    given_name  = "given_name",
    sub         = "sub"
  }
  groups_claim                 = "memberof"
  oidc_scopes                  = ["profile", "email", "openid"]
  user_claim                   = "sub"
  token_policies               = [vault_policy.groups_automation_devs.name]

}
