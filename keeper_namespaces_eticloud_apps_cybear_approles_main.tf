resource "vault_auth_backend" "approle" {
  provider = vault.cybear
  type     = "approle"

  tune {
    default_lease_ttl = "30m"
  }
}

#region RESOURCES FOR CI-JENKINS-APPROLE #######

data "local_file" "jenkins_policy_hcl" {
  filename = "policies/jenkins-policy.hcl"
}

# Create a jenkins policy in the eticloud/apps/cybear namespace
resource "vault_policy" "jenkins_policy" {
  provider = vault.cybear
  name     = "jenkins"
  policy   = data.local_file.jenkins_policy_hcl.content

  # lifecycle {
  #   replace_triggered_by = [
  #     data.local_file.ci-policy-hcl.content
  #   ]
  # }
}

resource "vault_approle_auth_backend_role" "jenkins_approle" {
  provider       = vault.cybear
  backend        = vault_auth_backend.approle.path
  role_name      = "cybear-jenkins-approle"
  token_policies = ["default", "jenkins"]
  depends_on     = [
    vault_policy.jenkins_policy
  ]
}

# Secret ID for the backend role. Required for automation in Jenkins.
resource "vault_approle_auth_backend_role_secret_id" "jenkins_backend_role_secret_id" {
  provider  = vault.cybear
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.jenkins_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into Jenkins.
resource "vault_kv_secret_v2" "jenkins-backend-secret" {
  provider  = vault.cybear
  mount     = "secret"
  name      = "approle/cybear-jenkins-approle"
  data_json = jsonencode(
    {
      role_name = vault_approle_auth_backend_role.jenkins_approle.role_name
      role_id   = vault_approle_auth_backend_role.jenkins_approle.role_id
      secret_id = vault_approle_auth_backend_role_secret_id.jenkins_backend_role_secret_id.secret_id
    }
  )
}

# TODO: automate rotating approle's RoleID and SecretID
# - generate this approle's Secret ID and Role ID and store it in Vault - in testing
# - create an automated job that rotates the Secret ID and Role ID for `cybear-jenkins-approle` in Jenkins Credentials.

#endregion

#region RESOURCES FOR CI-GHA-APPROLE #######

data "local_file" "gha_policy_hcl" {
  filename = "policies/gha-policy.hcl"
}

# Create a GHA policy in the eticloud/apps/cybear namespace
resource "vault_policy" "gha_policy" {
  provider = vault.cybear
  name     = "gha"
  policy   = data.local_file.gha_policy_hcl.content

  # lifecycle {
  #   replace_triggered_by = [
  #     data.local_file.ci-policy-hcl.content
  #   ]
  # }
}

resource "vault_approle_auth_backend_role" "gha_approle" {
  provider       = vault.cybear
  backend        = vault_auth_backend.approle.path
  role_name      = "cybear-gha-approle"
  token_policies = ["default", "gha"]
  depends_on     = [
    vault_policy.gha_policy
  ]
}

# Secret ID for the backend role. Required for automation in GitHub Actions.
resource "vault_approle_auth_backend_role_secret_id" "gha_backend_role_secret_id" {
  provider  = vault.cybear
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.gha_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into GitHub Actions.
resource "vault_kv_secret_v2" "gha_backend_secret" {
  provider  = vault.cybear
  mount     = "secret"
  name      = "approle/cybear-gha-approle"
  data_json = jsonencode(
    {
      role_name = vault_approle_auth_backend_role.gha_approle.role_name
      role_id   = vault_approle_auth_backend_role.gha_approle.role_id
      secret_id = vault_approle_auth_backend_role_secret_id.gha_backend_role_secret_id.secret_id
    }
  )
}

# TODO: automate rotating approle's RoleID and SecretID
# - generate this approle's Secret ID and Role ID and store it in Vault - in testing
# - create an automated job that rotates the Secret ID and Role ID for `ci-gha-approle` in GitHub Actions Secrets.

#endregion
