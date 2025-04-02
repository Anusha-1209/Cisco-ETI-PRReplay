locals {
  secret = {
    username       = data.vault_generic_secret.arangodb_secrets.data["username"]
    password       = data.vault_generic_secret.arangodb_secrets.data["password"]
    ca-certificate = data.vault_generic_secret.arangodb_secrets.data["ca.crt.b64"]
    topics        = data.vault_generic_secret.arangodb_secrets.data["topics"]
  }
}

// Secrets for aragodb authentication
resource "aws_secretsmanager_secret" "msk_connect_kg" {
  name        = "dragonfly-msk-connect-kg"
  description = "Secrets to connect to arangodb database."

  kms_key_id = aws_kms_key.encryption_key.arn
}

// Secret versions
resource "aws_secretsmanager_secret_version" "msk_connect_kg_password_v1" {
  secret_id     = aws_secretsmanager_secret.msk_connect_kg.id
  secret_string = jsonencode(local.secret)
}
