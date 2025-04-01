resource "vault_aws_secret_backend" "aws-motific-staging" {
  provider    = vault.vowel
  path        = "aws-motific-staging"
  description = "AWS Secrets Engine for CI access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-motific-staging.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-motific-staging.secret
}

resource "vault_aws_secret_backend_role" "jenkins-role" {
  provider        = vault.vowel
  backend         = vault_aws_secret_backend.aws-motific-staging.path
  name            = "jenkins-role"
  credential_type = "assumed_role"

  role_arns = [
    aws_iam_role.jenkins.arn,
  ]
}