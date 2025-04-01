resource "random_password" "password" {
  length  = 64
  special = true
}

resource "vault_generic_secret" "os_auth_credentials" {
  path = "secret/prod/os/${data.aws_region.current.name}/os-dragonfly-prod-1/master-user"

  data_json = jsonencode({
    username = var.os_master_user
    password = random_password.password.result
  })

  provider = vault.dragonfly
}

resource "vault_generic_secret" "connection" {
  path = "secret/prod/os/${data.aws_region.current.name}/os-dragonfly-prod-1/connection"
  data_json = jsonencode({
    username = var.os_master_user
    password = random_password.password.result
    endpoint = "https://${aws_opensearch_domain.dragonfly_prod_1_os.endpoint}"
  })

  provider = vault.dragonfly

  depends_on = [
    aws_opensearch_domain.dragonfly_prod_1_os
  ]
}