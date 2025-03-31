resource "vault_aws_secret_backend" "ci-aws-traiage-genai-common" {
  provider    = vault.traiage
  path        = "ci-aws-traiage-genai-common"
  description = "AWS Secrets Engine for CI-related access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-traiage-genai-common.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-traiage-genai-common.secret
}

resource "vault_aws_secret_backend_role" "traiage-genai-common-ci-role" {
  provider        = vault.traiage
  backend         = vault_aws_secret_backend.ci-aws-traiage-genai-common.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.ci-ecr-access.arn
  ]
}