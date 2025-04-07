variable "venture_name" {
  type    = string
  default = "argus" # <-- requires updating
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
  namespace = "eticloud/apps"
  alias     = "apps"
}

provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/argus" # <-- requires updating
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
  default_role       = "developer"
}



# vault roles
resource "vault_jwt_auth_backend_role" "admin" {
  depends_on = [vault_policy.policy["admin"], vault_policy.policy["developer"]]
  provider   = vault.venture
  role_name  = "admin"
  role_type  = "oidc"
  backend    = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "https://east.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
  "http://localhost:8250/oidc/callback"]
  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=outshift-${var.venture_name}-vault-admin,OU=Cisco Groups,DC=cisco,DC=com"
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
  token_policies = [vault_policy.policy["admin"].name,
  vault_policy.default.name]
}

resource "vault_jwt_auth_backend_role" "developer" {
  depends_on = [vault_policy.policy["developer"], vault_policy.policy["developer"]]
  provider   = vault.venture
  role_name  = "developer"
  role_type  = "oidc"
  backend    = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "https://east.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
  "http://localhost:8250/oidc/callback"]
  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=outshift-${var.venture_name}-vault-developer,OU=Cisco Groups,DC=cisco,DC=com"
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
  token_policies = [vault_policy.policy["developer"].name,
  vault_policy.default.name]
}

# vault default policy
resource "vault_policy" "default" {
  provider = vault.venture
  name     = "default"
  policy   = file(local.policies["default"])
}

# Define a map of policy names to filenames
locals {
  policies = {
    "admin"     = "policies/admin.hcl",
    "default"   = "policies/default.hcl",
    "developer" = "policies/developer.hcl",
  }
}

# Use for_each to create a local_file data source for each policy
data "local_file" "policy" {
  for_each = local.policies
  filename = each.value
}

# Use for_each to create a vault_policy resource for each policy
resource "vault_policy" "policy" {
  provider = vault.venture
  for_each = data.local_file.policy

  name   = each.key
  policy = each.value.content
}