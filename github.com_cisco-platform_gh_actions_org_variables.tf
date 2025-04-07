locals {
  github_variables = {
    "DEFAULT_RUNNER_GROUP"           = "SRE-Large-Runners"
    "ECR_PUBLIC_REGISTRY_ALIAS"      = "ciscoplatform"
    "GHCR_REGISTRY"                  = "ghcr.io/cisco-platform"
    "UBUNTU_RUNNER"                  = "ubuntu-latest"
    "KEEPER_URL"                     = "https://keeper.cisco.com"
    "VAULT_ADDR"                     = "https://keeper.cisco.com"
    "VAULT_NAMESPACE"                = "eticloud"
    "VAULT_SECRET_PATH"              = "ci/data/gha/gh-actions"
  }
}

resource "github_actions_organization_variable" "dynamic" {
  for_each = local.github_variables

  variable_name = each.key
  visibility    = "private"
  value         = each.value
}
