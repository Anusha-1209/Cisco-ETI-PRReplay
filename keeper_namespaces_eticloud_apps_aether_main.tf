provider "vault" {}

variable "venture_name" {
  type    = string
  default = "aether"
}

variable "oidc_client_id" {
  type    = string
  default = "DII9TO378NM0ZW02ABST"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/teamsecrets"
  alias     = "teamsecrets"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps"
  alias     = "apps"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/aether"
  alias     = "venture"
}

resource "vault_namespace" "namespace" {
  provider = vault.apps
  path     = var.venture_name
}

# key-value secrets engine
resource "vault_mount" "kvv2" {
  provider = vault.venture
  path     = "secret"
  type    = "kv"
  options = { version = "2" }
}

# OIDC Credentials
data "vault_generic_secret" "oidc_credential" {
  provider = vault.teamsecrets
  path = "secret/cisco_sso_auth_clients/vault_oidc_creds"
}

# oidc auth backend
resource "vault_jwt_auth_backend" "oidc" {
  provider           = vault.venture
  type               = "oidc"
  path               = "oidc"
  oidc_client_id     = var.oidc_client_id
  oidc_client_secret = data.vault_generic_secret.oidc_credential.data["client_secret"]
  oidc_discovery_url = "https://sso-dbbfec7f.sso.duosecurity.com/oidc/${var.oidc_client_id}"
  default_role       = "developer"
}



# vault roles
# Outshift Aether Vault Role
resource "vault_jwt_auth_backend_role" "aether" {
  depends_on = [vault_policy.aether]
  provider   = vault.venture
  role_name  = "aether"
  role_type  = "oidc"
  backend    = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=outshift-vault-aether,OU=Cisco Groups,DC=cisco,DC=com"
  }
  disable_bound_claims_parsing = true
  bound_claims_type            = "string"
  claim_mappings = {
    email       = "email",
    family_name = "family_name",
    given_name  = "given_name",
    sub         = "sub"
  }
  groups_claim = "memberof"
  oidc_scopes  = ["profile", "email", "openid"]
  user_claim   = "sub"
  token_policies = [vault_policy.aether.name]
}

resource "vault_policy" "aether" {
  provider = vault.venture
  name     = "aether"
  policy   = <<EOT
# Manage auth methods broadly across Vault
# List, create, update, and delete key/value secrets
path "aether/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}
