resource "random_password" "password" {
  length  = 64
  special = true
}

resource "vault_generic_secret" "os_auth_credentials" {
  path = "secret/prod/os/eu-central-1/os-dragonfly-prod-1/master-user"

  data_json = jsonencode({
    username = var.os_master_user
    password = random_password.password.result
  })

  provider = vault.dragonfly
}
