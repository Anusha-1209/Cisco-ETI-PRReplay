resource "vault_aws_secret_backend" "aws-kendra" {
  provider    = vault.kendra
  path        = "aws-genai-kendra"
  description = "AWS Secrets Engine for CI access to genai-kendra"

  access_key  = aws_iam_access_key.vault-secret-engine-user-kendra.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-kendra.secret
}

resource "vault_aws_secret_backend_role" "kendra-role" {
  provider        = vault.kendra
  backend         = vault_aws_secret_backend.aws-kendra.path
  name            = "vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.default-role.arn,
    aws_iam_role.custom-role.arn
  ]
}