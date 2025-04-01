provider "vault" {}

variable "venture_name" {
  type    = string
  default = "demo-labs" # <-- requires updating
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
  namespace = "eticloud/apps/demo-labs" # <-- requires updating
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
resource "vault_jwt_auth_backend_role" "admin" {
  depends_on                   = [ vault_policy.policy["admin"], vault_policy.policy["developer"] ]
  provider                     = vault.venture
  role_name                    = "admin"
  role_type                    = "oidc"
  backend                      = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris        = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://east.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences              = [var.oidc_client_id]
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
  groups_claim                 = "memberof"
  oidc_scopes                  = ["profile", "email", "openid"]
  user_claim                   = "sub"
  token_policies               = [vault_policy.policy["admin"].name,
                                  vault_policy.default.name]
}

resource "vault_jwt_auth_backend_role" "developer" {
  depends_on                   = [ vault_policy.policy["developer"], vault_policy.policy["developer"] ]
  provider                     = vault.venture
  role_name                    = "developer"
  role_type                    = "oidc"
  backend                      = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris        = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://east.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
                                  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences              = [var.oidc_client_id]
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
  groups_claim                 = "memberof"
  oidc_scopes                  = ["profile", "email", "openid"]
  user_claim                   = "sub"
  token_policies               = [vault_policy.policy["developer"].name,
                                  vault_policy.default.name]
}

# vault policies
resource "vault_policy" "default" {
  provider = vault.venture
  name     = "default"
  policy   = <<EOT
# Allow tokens to look up their own properties
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

# Allow a token to look up its own capabilities on a path
path "sys/capabilities-self" {
    capabilities = ["update"]
}

# Allow a token to look up its own entity by id or name
path "identity/entity/id/{{identity.entity.id}}" {
  capabilities = ["read"]
}
path "identity/entity/name/{{identity.entity.name}}" {
  capabilities = ["read"]
}


# Allow a token to look up its resultant ACL from all policies. This is useful
# for UIs. It is an internal path because the format may change at any time
# based on how the internal ACL features and capabilities change.
path "sys/internal/ui/resultant-acl" {
    capabilities = ["read"]
}

# Allow a token to renew a lease via lease_id in the request body; old path for
# old clients, new path for newer
path "sys/renew" {
    capabilities = ["update"]
}
path "sys/leases/renew" {
    capabilities = ["update"]
}

# Allow looking up lease properties. This requires knowing the lease ID ahead
# of time and does not divulge any sensitive information.
path "sys/leases/lookup" {
    capabilities = ["update"]
}

# Allow a token to manage its own cubbyhole
path "cubbyhole/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow a token to wrap arbitrary values in a response-wrapping token
path "sys/wrapping/wrap" {
    capabilities = ["update"]
}

# Allow a token to look up the creation time and TTL of a given
# response-wrapping token
path "sys/wrapping/lookup" {
    capabilities = ["update"]
}

# Allow a token to unwrap a response-wrapping token. This is a convenience to
# avoid client token swapping since this is also part of the response wrapping
# policy.
path "sys/wrapping/unwrap" {
    capabilities = ["update"]
}

# Allow general purpose tools
path "sys/tools/hash" {
    capabilities = ["update"]
}
path "sys/tools/hash/*" {
    capabilities = ["update"]
}

# Allow checking the status of a Control Group request if the user has the
# accessor
path "sys/control-group/request" {
    capabilities = ["update"]
}
EOT
}

# Define a map of policy names to filenames
locals {
  policies = {
    "developer"                             = "policies/developer.hcl",
    "admin"                                 = "policies/admin.hcl",
    "external-secrets-dev"                  = "policies/external-secrets-dev.hcl",
    "external-secrets"                      = "policies/external-secrets.hcl",
    "external-secrets-prod"                 = "policies/external-secrets-prod.hcl",
    "external-secrets-comn-dev-usw2-1"      = "policies/external-secrets-comn-dev-usw2-1.hcl",
    "external-secrets-comn-dev-use2-1"      = "policies/external-secrets-comn-dev-use2-1.hcl",
    "external-secrets-comn-staging-use2-1"  = "policies/external-secrets-comn-staging-use2-1.hcl",
    "external-secrets-comn-staging-usw2-1"  = "policies/external-secrets-comn-staging-usw2-1.hcl",
    "external-secrets-comn-prod-use2-1"     = "policies/external-secrets-comn-prod-use2-1.hcl",
    "external-secrets-comn-prod-usw2-1"     = "policies/external-secrets-comn-prod-usw2-1.hcl",
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