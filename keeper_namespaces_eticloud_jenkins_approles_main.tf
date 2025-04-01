# Create a jenkins policy in the eticloud/jenkins namespace
data "local_file" "jenkins_policy_hcl" {
  filename = "policies/jenkins-policy.hcl"
}

resource "vault_policy" "jenkins_policy" {
  provider = vault.jenkins
  name     = "jenkins"
  policy   = data.local_file.jenkins_policy_hcl.content

  # lifecycle {
  #   replace_triggered_by = [
  #     data.local_file.ci-policy-hcl.content
  #   ]
  # }
}

resource "vault_auth_backend" "approle" {
  provider = vault.jenkins
  type     = "approle"

  tune {
    default_lease_ttl = "30m"
  }
}

resource "vault_approle_auth_backend_role" "jenkins_approle" {
  provider       = vault.jenkins
  backend        = vault_auth_backend.approle.path
  role_name      = "jenkins"
  token_policies = ["default", "jenkins"]
  depends_on     = [
    vault_policy.jenkins_policy
  ]
}

# Secret ID for the backend role. Required for automation in Jenkins.
resource "vault_approle_auth_backend_role_secret_id" "jenkins_backend_role_secret_id" {
  provider  = vault.jenkins
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.jenkins_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into Jenkins.
resource "vault_kv_secret_v2" "jenkins-backend-secret" {
  provider  = vault.jenkins
  mount     = "secret"
  name      = "approle/jenkins"
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
# - create an automated job that rotates the Secret ID and Role ID for `ci-jenkins-approle` in Jenkins Credentials.

