data "vault_generic_secret" "github-webhook-secret" {
  provider = vault.eticloud
  path="secret/prod/github-webhook"
}

resource "aws_secretsmanager_secret" "webhook_secrets_manager" {
  name = "${var.appname_prefix}-webhooksecret"
  description = "Secrets Manager for storing Webhook Secret"
  force_overwrite_replica_secret = false
  # lifecycle {
  #   ignore_changes = [
  #     aws_secretsmanager_secret.webhook_secrets_manager
  #   ]
  # }
}
resource "aws_secretsmanager_secret_version" "webhook_secrets_manager_version" {
  secret_id     = aws_secretsmanager_secret.webhook_secrets_manager.id
  secret_string = data.vault_generic_secret.github-webhook-secret.data["github_secret"]
  # lifecycle {
  #   ignore_changes = [
  #     aws_secretsmanager_secret_version.aws_secretsmanager_secret_version
  #   ]
  # }
}