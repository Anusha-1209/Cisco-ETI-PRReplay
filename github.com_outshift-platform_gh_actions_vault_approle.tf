data "vault_auth_backend" "approle" {
  provider = vault.eticloud
  path = "approle"
}

resource "vault_policy" "github_actions" {
  provider = vault.eticloud
  name = "outshift-platform-github-actions"
  policy = <<EOF
path "ci/data/gha/gh-actions" {
  capabilities = ["read"]
}
path "auth/approle/role/github-actions" {
  capabilities = ["read"]
}
path "ci-aws-eti-ci/*" {
  capabilities = ["read"]
}
EOF
}

resource "vault_approle_auth_backend_role" "github_actions" {
  provider = vault.eticloud
  backend        = data.vault_auth_backend.approle.path
  role_name      = "github-actions"
  token_policies = [vault_policy.github_actions.name]
}

resource "vault_approle_auth_backend_role_secret_id" "github_actions" {
  provider = vault.eticloud
  backend = data.vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.github_actions.role_name
}

resource "vault_generic_secret" "gha_ci_secrets" {
  provider = vault.eticloud
  path     = "ci/gha/approle"
  data_json = <<EOT
  {
    "VAULT_APPROLE_ROLE_ID": "${vault_approle_auth_backend_role.github_actions.role_id}",
    "VAULT_APPROLE_SECRET_ID": "${vault_approle_auth_backend_role_secret_id.github_actions.secret_id}"
  }
  EOT
}