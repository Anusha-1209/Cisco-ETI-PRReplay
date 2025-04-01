resource "vault_aws_secret_backend" "aws-motific-preview" {
  provider    = vault.vowel
  path        = "aws-motific-preview"
  description = "AWS Secrets Engine for CI access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-motific-preview.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-motific-preview.secret
}

resource "vault_aws_secret_backend_role" "jenkins-role" {
  provider        = vault.vowel
  backend         = vault_aws_secret_backend.aws-motific-preview.path
  name            = "jenkins-role"
  credential_type = "assumed_role"

  role_arns = [
    aws_iam_role.jenkins.arn,
  ]
}