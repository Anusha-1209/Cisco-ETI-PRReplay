provider "vault" {}

variable "namespace" {
  type    = string
  default = "jenkins" # <-- requires updating
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/teamsecrets"
  alias     = "teamsecrets"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/jenkins" # <-- requires updating
  alias     = "jenkins"
}

variable "oidc_client_id" {
  type    = string
  default = "DII9TO378NM0ZW02ABST" # <-- requires updating
}

variable "venture_name" {
  type    = string
  default = "eticloud/jenkins"     # <-- requires updating
}

# OIDC Credentials
data "vault_generic_secret" "oidc_credential" {
  provider = vault.teamsecrets
  path = "secret/cisco_sso_auth_clients/vault_oidc_creds"
}

resource "vault_jwt_auth_backend" "oidc" {
  provider            = vault.jenkins
  type                = "oidc"
  path                = "oidc"
  oidc_client_id      = var.oidc_client_id
  default_role        = "admin"
  oidc_client_secret  = data.vault_generic_secret.oidc_credential.data["client_secret"]
  oidc_discovery_url = "https://sso-dbbfec7f.sso.duosecurity.com/oidc/${var.oidc_client_id}"
}

# resource "vault_namespace" "namespace" {
#   provider = vault.jenkins
#   path     = "eticloud/jenkins"
# }

resource "vault_policy" "admin" {
  name   = "admin"
  provider = vault.jenkins
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

resource "vault_jwt_auth_backend_role" "admin" {
  depends_on                   = [ vault_policy.admin ]
  provider                     = vault.jenkins
  role_name                    = "admin"
  role_type                    = "oidc"
  backend                      = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris        = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://east.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "http://localhost:8250/oidc/callback"]
  bound_audiences              = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=eti-sre-admin,OU=Cisco Groups,DC=cisco,DC=com"
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
  token_policies               = ["admin"]

}
