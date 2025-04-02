resource "vault_aws_secret_backend" "ci-aws-apisec" {
  provider    = vault.apisec
  path        = "ci-aws-apisec-dev"
  description = "AWS Secrets Engine for CI access to apisec-dev"

  access_key  = aws_iam_access_key.vault-secret-engine-user-apisec.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-apisec.secret
}

resource "vault_aws_secret_backend_role" "apisec-ci-role" {
  provider        = vault.apisec
  backend         = vault_aws_secret_backend.ci-aws-apisec.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.ci-default-role.arn,
    aws_iam_role.ci-s3-push.arn,
    aws_iam_role.ci-custom-role.arn
  ]
}