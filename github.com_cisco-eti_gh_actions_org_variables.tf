locals {
  github_variables = {
    "DEFAULT_RUNNER_GROUP" = "outshift-platform-large-runners"
    "ECR_PUBLIC_REGISTRY_ALIAS" = "ciscoeti"
    "GHCR_REGISTRY" = "ghcr.io/cisco-eti"
    "LATEST_SRE_BUILD_IMAGE" = "ghcr.io/cisco-eti/sre-pipeline-docker:2024.05.30-e409a0c-90"
    "SONAR_PROPERTIES_FILE" = "build/sonar-project.properties"
    "SONAR_SCANNER_CLI_DOCKER_IMAGE" = "ghcr.io/cisco-eti/sonar-scanner-cli:latest"
    "SRE_BUILD_IMAGE" = "ghcr.io/cisco-eti/sre-pipeline-docker:2024.05.30-e409a0c-91"
    "UBUNTU_RUNNER" = "ubuntu-latest"
    "KEEPER_URL" = "https://keeper.cisco.com"
    "VAULT_ADDR" = "https://keeper.cisco.com"
    "VAULT_NAMESPACE" = "eticloud"
    "VAULT_SECRET_PATH" = "ci/data/gha/gh-actions"
  }
}

resource "github_actions_organization_variable" "dynamic" {
  for_each      = local.github_variables

  variable_name = each.key
  visibility    = "private"
  value         = each.value
}