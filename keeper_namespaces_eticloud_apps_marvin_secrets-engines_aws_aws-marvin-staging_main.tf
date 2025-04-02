resource "vault_aws_secret_backend" "ci-aws-marvin" {
  provider    = vault.marvin
  path        = "ci-aws-marvin-staging"
  description = "AWS Secrets Engine for CI access to marvin-staging"

  access_key  = aws_iam_access_key.vault-secret-engine-user-marvin.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-marvin.secret
}

resource "vault_aws_secret_backend_role" "marvin-ci-role" {
  provider        = vault.marvin
  backend         = vault_aws_secret_backend.ci-aws-marvin.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.ci-default-role.arn,
    aws_iam_role.ci-s3-push.arn,
    aws_iam_role.ci-custom-role.arn
  ]
}