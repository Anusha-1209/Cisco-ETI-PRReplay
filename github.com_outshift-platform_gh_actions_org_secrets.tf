data "vault_generic_secret" "gha_ci_secrets" {
  provider = vault.eticloud
  path     = "ci/gha/gh-actions"
}

data "github_actions_organization_public_key" "gha_org_public_key" {
}

data "sodium_encrypted_item" "GHCR_TOKEN" {
  public_key_base64 = data.github_actions_organization_public_key.gha_org_public_key.key
  content_base64 = base64encode(data.vault_generic_secret.gha_ci_secrets.data["GHEC_PAT"])
}

data "sodium_encrypted_item" "GHCR_USERNAME" {
  public_key_base64 = data.github_actions_organization_public_key.gha_org_public_key.key
  content_base64 = base64encode(data.vault_generic_secret.gha_ci_secrets.data["GHEC_USERNAME"])
}

data "sodium_encrypted_item" "VAULT_APPROLE_ROLE_ID" {
  public_key_base64 = data.github_actions_organization_public_key.gha_org_public_key.key
  content_base64 = base64encode(data.vault_generic_secret.gha_ci_secrets.data["VAULT_APPROLE_ROLE_ID"])
}

data "sodium_encrypted_item" "VAULT_APPROLE_SECRET_ID" {
  public_key_base64 = data.github_actions_organization_public_key.gha_org_public_key.key
  content_base64 = base64encode(data.vault_generic_secret.gha_ci_secrets.data["VAULT_APPROLE_SECRET_ID"])
}

data "sodium_encrypted_item" "WEBEX_PLATFORM_NOTIFICATION_ROOM_ID" {
  public_key_base64 = data.github_actions_organization_public_key.gha_org_public_key.key
  content_base64 = base64encode(data.vault_generic_secret.gha_ci_secrets.data["WEBEX_PLATFORM_NOTIFICATION_ROOM_ID"])
}

data "sodium_encrypted_item" "WEBEX_TOKEN" {
  public_key_base64 = data.github_actions_organization_public_key.gha_org_public_key.key
  content_base64 = base64encode(data.vault_generic_secret.gha_ci_secrets.data["WEBEX_TOKEN"])
}

locals {
  github_secrets = {
    "GHCR_TOKEN" = data.sodium_encrypted_item.GHCR_TOKEN.encrypted_value_base64
    "GHCR_USERNAME" = data.sodium_encrypted_item.GHCR_USERNAME.encrypted_value_base64
    "VAULT_APPROLE_ROLE_ID" = data.sodium_encrypted_item.VAULT_APPROLE_ROLE_ID.encrypted_value_base64
    "VAULT_APPROLE_SECRET_ID" = data.sodium_encrypted_item.VAULT_APPROLE_SECRET_ID.encrypted_value_base64
    "WEBEX_PLATFORM_NOTIFICATION_ROOM_ID" = data.sodium_encrypted_item.WEBEX_PLATFORM_NOTIFICATION_ROOM_ID.encrypted_value_base64
    "WEBEX_TOKEN" = data.sodium_encrypted_item.WEBEX_TOKEN.encrypted_value_base64
  }
}
resource "github_actions_organization_secret" "dynamic" {
  for_each         = local.github_secrets
  secret_name      = each.key
  visibility       = "private"
  encrypted_value  = each.value
}