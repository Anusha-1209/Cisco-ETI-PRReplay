// Generate random passwords
resource "random_password" "password" {
  for_each = var.kafka_clients

  length  = 64
  special = false
}

// Save secrets in Vault
resource "vault_generic_secret" "msk_auth_credentials" {
  for_each = var.kafka_clients

  path = each.value.vault_path

  data_json = jsonencode({
    username = each.key
    password = random_password.password[each.key].result
  })

  provider = vault.dragonfly
}

// Secrets for SASL/SCRAM authentication
resource "aws_secretsmanager_secret" "msk_auth_credentials" {
  for_each = var.kafka_clients

  name        = "AmazonMSK_dragonfly-msk-eu1-${each.key}-auth"
  description = each.value.description

  kms_key_id = aws_kms_key.encryption_key.key_id
}

// Secret versions
resource "aws_secretsmanager_secret_version" "msk_auth_credentials_1" {
  for_each = var.kafka_clients

  secret_id     = aws_secretsmanager_secret.msk_auth_credentials[each.key].id
  secret_string = vault_generic_secret.msk_auth_credentials[each.key].data_json
}

// Secret policy
resource "aws_secretsmanager_secret_policy" "msk_secret_policy" {
  for_each = var.kafka_clients

  secret_arn = aws_secretsmanager_secret.msk_auth_credentials[each.key].arn
  policy     = data.aws_iam_policy_document.msk_secret_policy[each.key].json
}
