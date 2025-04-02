resource "vault_aws_secret_backend" "ci-aws-securecn" {
  provider    = vault.securecn
  path        = "ci-aws-securecn"
  description = "AWS Secrets Engine for CI-related access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-securecn.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-securecn.secret
}

resource "vault_aws_secret_backend_role" "securecn-ci-role" {
  provider        = vault.securecn
  backend         = vault_aws_secret_backend.ci-aws-securecn.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.ci-default-role.arn,
    aws_iam_role.ci-s3-push.arn
  ]
}