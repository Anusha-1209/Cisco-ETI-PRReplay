resource "vault_auth_backend" "approle" {
  provider = vault.eticloud
  type     = "approle"

  tune {
    default_lease_ttl = "30m"
  }
}

#region RESOURCES FOR CI-APPROLE #######

# Create a ci policy in the root namespace
data "local_file" "ci-policy-hcl" {
  filename = "policies/ci-policy.hcl"
}

resource "vault_policy" "ci_policy" {
  name   = "ci"
  policy = data.local_file.ci-policy-hcl.content

  # lifecycle {
  #   replace_triggered_by = [
  #     data.local_file.ci-policy-hcl.content
  #   ]
  # }
}

resource "vault_approle_auth_backend_role" "ci-approle" {
  backend        = vault_auth_backend.approle.path
  role_name      = "ci-approle"
  token_policies = ["default", "ci"]
}

# TODO: automate rotating approle's RoleID and SecretID
# - generate this approle's Secret ID and Role ID and store it in Vault - in testing
# - create an automated job that rotates the Secret ID and Role ID for `ci-jenkins-approle` in Jenkins Credentials.

#endregion

#region RESOURCES FOR ETICLOUD-AUDIT-APPROLE #######

# Data call to policy. Policy is read-only to ci-aws-eticloud/sts/eticloud-sre-audit-ro
data "local_file" "eticloud_audit_policy_hcl" {
  filename = "policies/eticloud-audit-policy.hcl"
}

# Policy is read-only to ci-aws-eticloud/sts/eticloud-sre-audit-ro
resource "vault_policy" "eticloud_audit_policy" {
  provider = vault.eticloud
  name     = "eticloud-audit-policy"
  policy   = data.local_file.eticloud_audit_policy_hcl.content
}

# Approle backend
resource "vault_auth_backend" "eticloud_audit_backend_approle" {
  provider  = vault.eticloud
  type      = "approle"
  path      = "eticloud-audit-approle"
}
# Approle backend role. Allows access to the eticloud-audit-policy
resource "vault_approle_auth_backend_role" "eticloud_audit_backend_role" {
  provider       = vault.eticloud
  backend        = vault_auth_backend.eticloud_audit_backend_approle.path
  role_name      = "eticloud-audit-role"
  token_policies = ["default", "eticloud-audit-policy"]
  depends_on     = [
    vault_policy.eticloud_audit_policy
  ]
}
# Secret ID for the backend role. Required for automation in Jenkins.
resource "vault_approle_auth_backend_role_secret_id" "eticloud_audit_backend_role_secret_id" {
    provider  = vault.eticloud
    backend   = vault_auth_backend.eticloud_audit_backend_approle.path
    role_name = vault_approle_auth_backend_role.eticloud_audit_backend_role.role_name

}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into Jenkins.
resource "vault_kv_secret_v2" "eticloud-audit-backend-secret" {
    provider  = vault.eticloud
    mount     = "ci"
    name      = "approle/eticloud-audit"
    data_json = jsonencode(
      {
        role_name = vault_approle_auth_backend_role.eticloud_audit_backend_role.role_name
        role_id   = vault_approle_auth_backend_role.eticloud_audit_backend_role.role_id
        secret_id = vault_approle_auth_backend_role_secret_id.eticloud_audit_backend_role_secret_id.secret_id
      }
    )
}

# TODO: automate rotating approle's RoleID and SecretID
# - generate this approle's Secret ID and Role ID and store it in Vault - in testing
# - create an automated job that rotates the Secret ID and Role ID for `ci-jenkins-approle` in Jenkins Credentials.

#endregion

#region RESOURCES FOR CI-JENKINS-APPROLE #######

data "local_file" "jenkins_policy_hcl" {
  filename = "policies/ci-jenkins-policy.hcl"
}

resource "vault_policy" "ci_jenkins_policy" {
  provider = vault.eticloud
  name     = "ci-jenkins"
  policy   = data.local_file.jenkins_policy_hcl.content

  # lifecycle {
  #   replace_triggered_by = [
  #     data.local_file.ci-policy-hcl.content
  #   ]
  # }
}

resource "vault_approle_auth_backend_role" "ci_jenkins_approle" {
  provider       = vault.eticloud
  backend        = vault_auth_backend.approle.path
  role_name      = "ci-jenkins-approle"
  token_policies = ["default", "ci-jenkins"]
  depends_on     = [
    vault_policy.ci_jenkins_policy
  ]
}

# Secret ID for the backend role. Required for automation in Jenkins.
resource "vault_approle_auth_backend_role_secret_id" "ci_jenkins_backend_role_secret_id" {
  provider  = vault.eticloud
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ci_jenkins_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into Jenkins.
resource "vault_kv_secret_v2" "ci_jenkins_backend_secret" {
  provider  = vault.eticloud
  mount     = "ci"
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
  provider = vault.eticloud
  name     = "ci-gha"
  policy   = data.local_file.gha_policy_hcl.content

  # lifecycle {
  #   replace_triggered_by = [
  #     data.local_file.ci-policy-hcl.content
  #   ]
  # }
}

resource "vault_approle_auth_backend_role" "ci_gha_approle" {
  provider       = vault.eticloud
  backend        = vault_auth_backend.approle.path
  role_name      = "ci-gha-approle"
  token_policies = ["default", "ci-gha"]
  depends_on     = [
    vault_policy.ci_gha_policy
  ]
}

# Secret ID for the backend role. Required for automation in GitHub Actions.
resource "vault_approle_auth_backend_role_secret_id" "ci_gha_backend_role_secret_id" {
  provider  = vault.eticloud
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ci_gha_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into GitHub Actions.
resource "vault_kv_secret_v2" "ci_gha_backend_secret" {
  provider  = vault.eticloud
  mount     = "ci"
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

#region RESOURCES FOR SELF-SERVICE-APPROLE #######

data "local_file" "self_service_policy_hcl" {
  filename = "policies/self-service-policy.hcl"
}

resource "vault_policy" "self_service_policy" {
  provider = vault.eticloud
  name     = "self-service-approle"
  policy   = data.local_file.self_service_policy_hcl.content

  # lifecycle {
  #   replace_triggered_by = [
  #     data.local_file.self-service-policy-hcl.content
  #   ]
  # }
}

resource "vault_approle_auth_backend_role" "self_service_approle" {
  provider       = vault.eticloud
  backend        = vault_auth_backend.approle.path
  role_name      = "self-service-approle"
  token_policies = ["default", "self-service-approle"]
  depends_on     = [
    vault_policy.self_service_policy
  ]
}

# Secret ID for the backend role. Required for automation.
resource "vault_approle_auth_backend_role_secret_id" "self_service_backend_role_secret_id" {
  provider  = vault.eticloud
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.self_service_approle.role_name
}

# Creates a secret with the backend role name, id, and secret id. Will be entered manually into Jenkins.
resource "vault_kv_secret_v2" "self_service_backend_secret" {
  provider  = vault.eticloud
  mount     = "ci"
  name      = "approle/self-service-approle"
  data_json = jsonencode(
    {
      role_name = vault_approle_auth_backend_role.self_service_approle.role_name
      role_id   = vault_approle_auth_backend_role.self_service_approle.role_id
      secret_id = vault_approle_auth_backend_role_secret_id.self_service_backend_role_secret_id.secret_id
    }
  )
}

# TODO: automate rotating approle's RoleID and SecretID
# - generate this approle's Secret ID and Role ID and store it in Vault - in testing
# - create an automated job that rotates the Secret ID and Role ID for `self-service-approle`.

#endregion