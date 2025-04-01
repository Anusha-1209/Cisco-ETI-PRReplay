resource "vault_auth_backend" "approle" {
  provider = vault.traiage
  type     = "approle"

  tune {
    default_lease_ttl = "30m"
  }
}

// Jenkins
data "local_file" "jenkins_policy_hcl" {
  filename = "policies/ci-jenkins-policy.hcl"
}

resource "vault_policy" "ci_jenkins_policy" {
  provider = vault.traiage
  name     = "ci-jenkins"
  policy   = data.local_file.jenkins_policy_hcl.content
}

resource "vault_approle_auth_backend_role" "ci_jenkins_approle" {
  provider       = vault.traiage
  backend        = vault_auth_backend.approle.path
  role_name      = "ci-jenkins-approle"
  token_policies = ["default", "ci-jenkins"]
  depends_on     = [
    vault_policy.ci_jenkins_policy
  ]
}

resource "vault_approle_auth_backend_role_secret_id" "ci_jenkins_backend_role_secret_id" {
  provider  = vault.traiage
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ci_jenkins_approle.role_name
}

resource "vault_kv_secret_v2" "ci_jenkins_backend_secret" {
  provider  = vault.traiage
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

// GHA
data "local_file" "gha_policy_hcl" {
  filename = "policies/ci-gha-policy.hcl"
}

resource "vault_policy" "ci_gha_policy" {
  provider = vault.traiage
  name     = "ci-gha"
  policy   = data.local_file.gha_policy_hcl.content
}

resource "vault_approle_auth_backend_role" "ci_gha_approle" {
  provider       = vault.traiage
  backend        = vault_auth_backend.approle.path
  role_name      = "ci-gha-approle"
  token_policies = ["default", "ci-gha"]
  depends_on     = [
    vault_policy.ci_gha_policy
  ]
}

resource "vault_approle_auth_backend_role_secret_id" "ci_gha_backend_role_secret_id" {
  provider  = vault.traiage
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ci_gha_approle.role_name
}

resource "vault_kv_secret_v2" "ci_gha_backend_secret" {
  provider  = vault.traiage
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


