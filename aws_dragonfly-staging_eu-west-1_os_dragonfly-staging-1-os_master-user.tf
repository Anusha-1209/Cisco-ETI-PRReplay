resource "random_password" "password" {
  length  = 64
  special = true
}

resource "vault_generic_secret" "os_auth_credentials" {
  path = "secret/staging/os/eu-west-1/dragonfly-staging-1-os/master-user"

  data_json = jsonencode({
    username = var.os_master_user
    password = random_password.password.result
  })

  provider = vault.dragonfly
}

resource "vault_generic_secret" "connection" {
  path = "secret/staging/os/eu-west-1/dragonfly-staging-1-os/connection"
  data_json = jsonencode({
    username = var.os_master_user
    password = random_password.password.result
    endpoint = "https://${aws_opensearch_domain.dragonfly_staging_1_os.endpoint}"
  })

  provider = vault.dragonfly

  depends_on = [
    aws_opensearch_domain.dragonfly_staging_1_os
  ]
}
