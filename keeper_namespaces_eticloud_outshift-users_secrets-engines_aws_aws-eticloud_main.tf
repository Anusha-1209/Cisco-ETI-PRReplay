resource "vault_aws_secret_backend" "dev-sandbox-aws-eticloud" {
  provider    = vault.eticloud
  path        = "dev-sandbox-aws-eticloud"
  description = "AWS Secrets Engine for Dev Sandbox access"

  access_key  = aws_iam_access_key.vault-secret-engine-dev-sandbox.id
  secret_key  = aws_iam_access_key.vault-secret-engine-dev-sandbox.secret
}

resource "vault_aws_secret_backend_role" "dev-sandbox-vault-role" {
  provider        = vault.eticloud
  backend         = vault_aws_secret_backend.dev-sandbox-aws-eticloud.path
  name            = "dev-sandbox-vault-role"
  credential_type = "assumed_role"

  role_arns = [
    aws_iam_role.dev-sandbox-ecr-access.arn,
  ]
}