locals {
  project = "gcp-etigcp-nprd-12855"
}

# GCP engine creation
resource "vault_gcp_secret_backend" "gcp_k8sec_dev_1" {
  provider                  = vault.securecn
  path                      = "gcp_k8sec_dev_1"
  description               = "GCP Secrets Engine for CI-related access"
  default_lease_ttl_seconds = 900
  max_lease_ttl_seconds     = 1000

  credentials               = base64decode(google_service_account_key.vault_ci_gcp_engine_key.private_key)
}

# AppRoles/RoleSets assignment
resource "vault_gcp_secret_roleset" "viewer_role" {
  provider     = vault.securecn
  backend      = vault_gcp_secret_backend.gcp_k8sec_dev_1.path
  roleset      = "viewer-role"
  secret_type  = "access_token"
  project      = local.project
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${local.project}"

    # TODO: replace with narrow-scope roles
    roles = [
      "roles/viewer",
    ]
  }

  depends_on     = [
    google_project_iam_member.security_admin,
    google_project_iam_member.editor
  ]
}

resource "vault_gcp_secret_roleset" "gar_publish_role" {
  provider     = vault.securecn
  backend      = vault_gcp_secret_backend.gcp_k8sec_dev_1.path
  roleset      = "gar-publish-role"
  secret_type  = "access_token"
  project      = local.project
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${local.project}"

    # TODO: replace with narrow-scope roles
    roles = [
      "roles/artifactregistry.admin",
      "roles/artifactregistry.writer",
      "roles/storage.admin",
    ]
  }

  depends_on     = [
    google_project_iam_member.security_admin,
    google_project_iam_member.editor
  ]
}

resource "vault_gcp_secret_roleset" "kubernetes_role" {
  provider     = vault.securecn
  backend      = vault_gcp_secret_backend.gcp_k8sec_dev_1.path
  roleset      = "kubernetes-role"
  secret_type  = "access_token"
  project      = local.project
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${local.project}"

    # TODO: replace with narrow-scope roles
    roles = [
      "roles/container.admin",
      "roles/container.clusterAdmin",
      "roles/container.clusterAdmin",
    ]
  }

  depends_on     = [
    google_project_iam_member.security_admin,
    google_project_iam_member.editor
  ]
}

resource "vault_gcp_secret_roleset" "terraform_role" {
  provider     = vault.securecn
  backend      = vault_gcp_secret_backend.gcp_k8sec_dev_1.path
  roleset      = "terraform-role"
  secret_type  = "access_token"
  project      = local.project
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${local.project}"

    # TODO: replace with narrow-scope roles
    roles = [
      "roles/compute.networkAdmin",
      "roles/editor",
      "roles/iam.securityAdmin",
      "roles/iam.serviceAccountAdmin",
      "roles/container.admin",
      "roles/container.clusterAdmin",
      "roles/monitoring.admin",
      "roles/artifactregistry.admin",
      "roles/run.admin",
      "roles/compute.admin",
      "roles/containerregistry.ServiceAgent",
      "roles/dns.admin",
      "roles/container.admin",
      "roles/container.clusterAdmin",
      "roles/monitoring.admin",
      "roles/artifactregistry.admin",
      "roles/run.admin",
      "roles/compute.admin",
      "roles/containerregistry.ServiceAgent",
      "roles/dns.admin",
    ]
  }

  depends_on     = [
    google_project_iam_member.security_admin,
    google_project_iam_member.editor
  ]
}
