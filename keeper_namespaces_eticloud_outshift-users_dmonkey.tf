# Outshift dmonkey Vault Role
resource "vault_jwt_auth_backend_role" "dmonkey" {
  depends_on = [vault_policy.dmonkey]
  provider   = vault.venture
  role_name  = "dmonkey"
  role_type  = "oidc"
  backend    = vault_jwt_auth_backend.oidc.path
  allowed_redirect_uris = ["https://keeper.cisco.com/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  "https://west.keeper.cisco.com/ui/vault/auth/oidc/oidc/callback"]
  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    memberof = "CN=outshift-vault-dmonkey,OU=Cisco Groups,DC=cisco,DC=com"
  }
  disable_bound_claims_parsing = true
  bound_claims_type            = "string"
  claim_mappings = {
    email       = "email",
    family_name = "family_name",
    given_name  = "given_name",
    sub         = "sub"
  }
  groups_claim   = "memberof"
  oidc_scopes    = ["profile", "email", "openid"]
  user_claim     = "sub"
  token_policies = [vault_policy.dmonkey.name, vault_policy.default.name]
}
resource "vault_policy" "dmonkey" {
  provider = vault.venture
  name     = "dmonkey"
  policy   = <<EOT
# Manage auth methods broadly across Vault
# List, create, update, and delete key/value secrets
path "dmonkey/*"
{
  capabilities = ["read", "list"]
}
EOT
}
