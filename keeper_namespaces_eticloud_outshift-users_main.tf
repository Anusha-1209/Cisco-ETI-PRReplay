provider "vault" {}

variable "venture_name" {
  type    = string
  default = "outshift-users" # <-- requires updating
}

variable "oidc_client_id" {
  type    = string
  default = "DII9TO378NM0ZW02ABST" # <-- requires updating
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/teamsecrets"
  alias     = "teamsecrets"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
  alias     = "eticloud"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/outshift-users" # <-- requires updating
  alias     = "venture"
}
resource "vault_namespace" "namespace" {
  provider = vault.eticloud
  path     = var.venture_name
}

# key-value secrets engine
resource "vault_mount" "csm" {
  provider = vault.venture
  path     = "csm"
  type     = "kv"
  options  = { version = "2" }
}

resource "vault_mount" "genai" {
  provider = vault.venture
  path     = "genai"
  type     = "kv"
  options  = { version = "2" }
}

resource "vault_mount" "generic" {
  provider = vault.venture
  path     = "generic"
  type     = "kv"
  options  = { version = "2" }
}

resource "vault_mount" "smith" {
  provider = vault.venture
  path     = "smith"
  type     = "kv"
  options  = { version = "2" }
}

# OIDC Credentials
data "vault_generic_secret" "oidc_credential" {
  provider = vault.teamsecrets
  path     = "secret/cisco_sso_auth_clients/vault_oidc_creds"
}

# oidc auth backend
resource "vault_jwt_auth_backend" "oidc" {
  provider           = vault.venture
  type               = "oidc"
  path               = "oidc"
  oidc_client_id     = var.oidc_client_id
  oidc_client_secret = data.vault_generic_secret.oidc_credential.data["client_secret"]
  oidc_discovery_url = "https://sso-dbbfec7f.sso.duosecurity.com/oidc/${var.oidc_client_id}"
  default_role       = "generic-user"
}

# Outshift smith Vault Role
resource "vault_jwt_auth_backend_role" "smith" {
  depends_on = [vault_policy.smith]
  provider   = vault.venture
  role_name  = "smith"
  role_type  = "oidc"
  backend    = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=outshift-vault-smith,OU=Cisco Groups,DC=cisco,DC=com"
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
  token_policies = [vault_policy.smith.name]
}
resource "vault_policy" "smith" {
  provider = vault.venture
  name     = "smith"
  policy   = <<EOT
# Manage auth methods broadly across Vault
# List, create, update, and delete key/value secrets
path "smith/*"
{
  capabilities = ["read", "list"]
}
EOT
}

# Outshift engineering_rd Vault Role
resource "vault_jwt_auth_backend_role" "engineering_rd" {
  depends_on = [vault_policy.engineering_rd]
  provider   = vault.venture
  role_name  = "engineering_rd"
  role_type  = "oidc"
  backend    = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=outshift-vault-engineering-rd,OU=Cisco Groups,DC=cisco,DC=com"
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
  token_policies = [vault_policy.engineering_rd.name]
}
resource "vault_policy" "engineering_rd" {
  provider = vault.venture
  name     = "engineering_rd"
  policy   = <<EOT
# Manage auth methods broadly across Vault
# List, create, update, and delete key/value secrets
path "engineering_rd/*"
{
  capabilities = ["read", "list"]
}
EOT
}

# Outshift ragv2 Vault Role
resource "vault_jwt_auth_backend_role" "ragv2" {
  depends_on = [vault_policy.ragv2]
  provider   = vault.venture
  role_name  = "ragv2"
  role_type  = "oidc"
  backend    = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=outshift-vault-ragv2,OU=Cisco Groups,DC=cisco,DC=com"
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
  token_policies = [vault_policy.ragv2.name]
}

resource "vault_policy" "ragv2" {
  provider = vault.venture
  name     = "ragv2"
  policy   = <<EOT
# Manage auth methods broadly across Vault
# List, create, update, and delete key/value secrets
path "outshift_foundational_services/azure-ai/ragv2/*"
{
  capabilities = ["read", "list"]
}
EOT
}