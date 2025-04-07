// Secrets for SASL/SCRAM authentication
resource "aws_secretsmanager_secret" "msk_auth_credentials" {
  for_each = var.kafka_clients

  name        = "AmazonMSK_marvin-dev-use2-1-msk-${each.key}-auth"
  description = each.value.description

  kms_key_id = aws_kms_key.encryption_key.key_id
}

// Secret versions
resource "aws_secretsmanager_secret_version" "msk_auth_credentials_1" {
  for_each = var.kafka_clients

  secret_id     = aws_secretsmanager_secret.msk_auth_credentials[each.key].id
  secret_string = data.vault_generic_secret.msk_auth_credentials[each.key].data_json
}

// Secret policy
resource "aws_secretsmanager_secret_policy" "msk_secret_policy" {
  for_each = var.kafka_clients

  secret_arn = aws_secretsmanager_secret.msk_auth_credentials[each.key].arn
  policy     = data.aws_iam_policy_document.msk_secret_policy[each.key].json
}
