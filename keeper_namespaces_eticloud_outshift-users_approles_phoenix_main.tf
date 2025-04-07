resource "vault_auth_backend" "approle" {
  provider = vault.phoenix
  type     = "approle"

  tune {
    default_lease_ttl = "30m"
  }
}

#region RESOURCES FOR CI-GHA-APPROLE #######

data "local_file" "gha_policy_hcl" {
  filename = "policies/phoenix-ci-gha-policy.hcl"
}

resource "vault_policy" "ci_gha_policy" {
  provider = vault.phoenix
  name     = "ci-gha"
  policy   = data.local_file.gha_policy_hcl.content
}

resource "vault_approle_auth_backend_role" "ci_gha_approle" {
  provider       = vault.phoenix
  backend        = vault_auth_backend.approle.path
  role_name      = "ci-gha-approle"
  token_policies = ["default", "ci-gha"]
  depends_on     = [
    vault_policy.ci_gha_policy
  ]
}

# Secret ID for the backend role. Required for automation in GitHub Actions.
resource "vault_approle_auth_backend_role_secret_id" "ci_gha_backend_role_secret_id" {
  provider  = vault.phoenix
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ci_gha_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into GitHub Actions.
resource "vault_kv_secret_v2" "ci_gha_backend_secret" {
  provider  = vault.phoenix
  mount     = "secret"
  name      = "approle/ci-gha-approle"
  data_json = jsonencode(
    {
      role_name = vault_approle_auth_backend_role.ci_gha_approle.role_name
      role_id   = vault_approle_auth_backend_role.ci_gha_approle.role_id
      secret_id = vault_approle_auth_backend_role_secret_id.ci_gha_backend_role_secret_id.secret_id
    }
  )
}

#endregion
