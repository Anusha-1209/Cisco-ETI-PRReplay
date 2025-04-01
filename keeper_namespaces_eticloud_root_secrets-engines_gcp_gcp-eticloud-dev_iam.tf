data "google_iam_policy" "admin" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "user:dneduva@cisco.com",
    ]
  }
}

# GCP Service Account creation
resource "google_service_account" "vault_ci_gcp_engine" {
  project      = local.project
  account_id   = "vault-ci-gcp-engine"
  display_name = "Service account used for Vault (Keeper) AppRole integration"
}

# GCP Service Account IAM policy attachment
resource "google_service_account_iam_policy" "admin_account_iam" {
  service_account_id = google_service_account.vault_ci_gcp_engine.name
  policy_data        = data.google_iam_policy.admin.policy_data
}

# GCP Service Account permissions
resource "google_project_iam_member" "security_admin" {
  project = local.project
  role    = "roles/iam.securityAdmin"
  member  = "serviceAccount:${google_service_account.vault_ci_gcp_engine.email}"
}

resource "google_project_iam_member" "editor" {
  project = local.project
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.vault_ci_gcp_engine.email}"
}

# Create a new key for the service account
resource "google_service_account_key" "vault_ci_gcp_engine_key" {
  service_account_id = google_service_account.vault_ci_gcp_engine.name
}