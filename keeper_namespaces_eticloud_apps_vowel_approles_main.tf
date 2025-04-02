resource "vault_auth_backend" "approle" {
  provider = vault.vowel
  type     = "approle"

  tune {
    default_lease_ttl = "30m"
  }
}

#region RESOURCES FOR CI-JENKINS-APPROLE #######
data "local_file" "jenkins_policy_hcl" {
  filename = "policies/ci-jenkins-policy.hcl"
}

resource "vault_policy" "jenkins_policy" {
  provider = vault.vowel
  name     = "ci-jenkins"
  policy   = data.local_file.jenkins_policy_hcl.content
}

resource "vault_approle_auth_backend_role" "jenkins_approle" {
  provider       = vault.vowel
  backend        = vault_auth_backend.approle.path
  role_name      = "ci-jenkins-approle"
  token_policies = ["default", "ci-jenkins"]
  depends_on     = [
    vault_policy.jenkins_policy
  ]
}

# Secret ID for the backend role. Required for automation in Jenkins.
resource "vault_approle_auth_backend_role_secret_id" "jenkins_backend_role_secret_id" {
  provider  = vault.vowel
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.jenkins_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into Jenkins.
resource "vault_kv_secret_v2" "jenkins_backend_secret" {
  provider  = vault.vowel
  mount     = "secret"
  name      = "approle/ci-jenkins-approle"
  data_json = jsonencode(
    {
      role_name = vault_approle_auth_backend_role.jenkins_approle.role_name
      role_id   = vault_approle_auth_backend_role.jenkins_approle.role_id
      secret_id = vault_approle_auth_backend_role_secret_id.jenkins_backend_role_secret_id.secret_id
    }
  )
}
