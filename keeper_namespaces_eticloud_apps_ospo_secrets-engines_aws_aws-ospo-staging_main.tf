resource "vault_aws_secret_backend" "ci-aws-ospo" {
  provider    = vault.ospo
  path        = "ci-aws-ospo-staging"
  description = "AWS Secrets Engine for CI access to ospo-staging"

  access_key  = aws_iam_access_key.vault-secret-engine-user-ospo.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-ospo.secret
}

resource "vault_aws_secret_backend_role" "ospo-ci-role" {
  provider        = vault.ospo
  backend         = vault_aws_secret_backend.ci-aws-ospo.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.ci-default-role.arn,
    aws_iam_role.ci-s3-push.arn,
    aws_iam_role.ci-custom-role.arn
  ]
}