resource "vault_aws_secret_backend" "ci-aws-synthetica-dev" {
  provider    = vault.synthetica
  path        = "ci-aws-synthetica-dev"
  description = "AWS Secrets Engine for CI-related access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-synthetica-dev.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-synthetica-dev.secret
}

resource "vault_aws_secret_backend_role" "synthetica-dev-ci-role" {
  provider        = vault.synthetica
  backend         = vault_aws_secret_backend.ci-aws-synthetica-dev.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.ci-ecr-access.arn
  ]
}