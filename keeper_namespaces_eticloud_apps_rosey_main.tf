provider "vault" {}

variable "venture_name" {
  type    = string
  default = "rosey" # <-- requires updating
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
  namespace = "eticloud/apps/rosey" # <-- requires updating
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
  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=eti-${var.venture_name}-vault-admin,OU=Cisco Groups,DC=cisco,DC=com"
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
  vault_policy.policy["default"].name]
}

resource "vault_jwt_auth_backend_role" "developer" {
  depends_on = [vault_policy.policy["developer"], vault_policy.policy["developer"]]
  provider   = vault.venture
  role_name  = "developer"
  role_type  = "oidc"
  backend    = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "https://east.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=eti-${var.venture_name}-vault-developer,OU=Cisco Groups,DC=cisco,DC=com"
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
  vault_policy.policy["default"].name]
}

# Define a map of policy names to filenames
locals {
  policies = {
    "developer"                             = "policies/developer.hcl",
    "admin"                                 = "policies/admin.hcl",
    "external-secrets-dev"                  = "policies/external-secrets-dev.hcl",
    "external-secrets-staging"              = "policies/external-secrets-staging.hcl",
    "external-secrets-prod"                 = "policies/external-secrets-prod.hcl",
    "external-secrets-comn-dev-use2-1"      = "policies/external-secrets-comn-dev-use2-1.hcl",
    "external-secrets-rosey-dev-euw1-1.hcl" = "policies/external-secrets-rosey-dev-euw1-1.hcl",
    "external-secrets-cnapp-staging-euc1-1" = "policies/external-secrets-cnapp-staging-euc1-1.hcl",
    "external-secrets-cnapp-staging-use2-1" = "policies/external-secrets-cnapp-staging-use2-1.hcl",
    "external-secrets-cnapp-prod-euc1-1"    = "policies/external-secrets-cnapp-prod-euc1-1.hcl",
    "external-secrets-cnapp-prod-use2-1"    = "policies/external-secrets-cnapp-prod-use2-1.hcl",
    "default"                               = "policies/default.hcl",
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
