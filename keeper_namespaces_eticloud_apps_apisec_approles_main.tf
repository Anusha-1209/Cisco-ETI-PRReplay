resource "vault_auth_backend" "approle" {
  provider = vault.apisec
  type     = "approle"

  tune {
    default_lease_ttl = "30m"
  }
}

#region RESOURCES FOR CI-JENKINS-APPROLE #######
data "local_file" "jenkins_policy_hcl" {
  filename = "policies/ci-jenkins-policy.hcl"
}

resource "vault_policy" "ci_jenkins_policy" {
  provider = vault.apisec
  name     = "ci-jenkins"
  policy   = data.local_file.jenkins_policy_hcl.content

  # lifecycle {
  #   replace_triggered_by = [
  #     data.local_file.ci-policy-hcl.content
  #   ]
  # }
}

resource "vault_approle_auth_backend_role" "ci_jenkins_approle" {
  provider       = vault.apisec
  backend        = vault_auth_backend.approle.path
  role_name      = "ci-jenkins-approle"
  token_policies = ["default", "ci-jenkins"]
  depends_on     = [
    vault_policy.ci_jenkins_policy
  ]
}

# Secret ID for the backend role. Required for automation in Jenkins.
resource "vault_approle_auth_backend_role_secret_id" "ci_jenkins_backend_role_secret_id" {
  provider  = vault.apisec
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ci_jenkins_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into Jenkins.
resource "vault_kv_secret_v2" "ci_jenkins_backend_secret" {
  provider  = vault.apisec
  mount     = "secret"
  name      = "approle/ci-jenkins-approle"
  data_json = jsonencode(
    {
      role_name = vault_approle_auth_backend_role.ci_jenkins_approle.role_name
      role_id   = vault_approle_auth_backend_role.ci_jenkins_approle.role_id
      secret_id = vault_approle_auth_backend_role_secret_id.ci_jenkins_backend_role_secret_id.secret_id
    }
  )
}

# TODO: automate rotating approle's RoleID and SecretID
# - generate this approle's Secret ID and Role ID and store it in Vault - in testing
# - create an automated job that rotates the Secret ID and Role ID for `ci-jenkins-approle` in Jenkins Credentials.

#endregion

#region RESOURCES FOR CI-GHA-APPROLE #######

data "local_file" "gha_policy_hcl" {
  filename = "policies/ci-gha-policy.hcl"
}

resource "vault_policy" "ci_gha_policy" {
  provider = vault.apisec
  name     = "ci-gha"
  policy   = data.local_file.gha_policy_hcl.content

  # lifecycle {
  #   replace_triggered_by = [
  #     data.local_file.ci-policy-hcl.content
  #   ]
  # }
}

resource "vault_approle_auth_backend_role" "ci_gha_approle" {
  provider       = vault.apisec
  backend        = vault_auth_backend.approle.path
  role_name      = "ci-gha-approle"
  token_policies = ["default", "ci-gha"]
  depends_on     = [
    vault_policy.ci_gha_policy
  ]
}

# Secret ID for the backend role. Required for automation in GitHub Actions.
resource "vault_approle_auth_backend_role_secret_id" "ci_gha_backend_role_secret_id" {
  provider  = vault.apisec
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ci_gha_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into GitHub Actions.
resource "vault_kv_secret_v2" "ci_gha_backend_secret" {
  provider  = vault.apisec
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

# TODO: automate rotating approle's RoleID and SecretID
# - generate this approle's Secret ID and Role ID and store it in Vault - in testing
# - create an automated job that rotates the Secret ID and Role ID for `ci-gha-approle` in GitHub Actions Secrets.

#endregion
