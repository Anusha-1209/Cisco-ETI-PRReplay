resource "vault_aws_secret_backend" "ci-aws-kendra" {
  provider    = vault.kendra
  path        = "ci-aws-genai-kendra"
  description = "AWS Secrets Engine for CI access to genai-kendra"

  access_key  = aws_iam_access_key.vault-secret-engine-user-kendra.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-kendra.secret
}

resource "vault_aws_secret_backend_role" "kendra-ci-role" {
  provider        = vault.kendra
  backend         = vault_aws_secret_backend.ci-aws-kendra.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.ci-default-role.arn,
    aws_iam_role.ci-custom-role.arn
  ]
}