resource "vault_aws_secret_backend" "aws-promptintel-dev" {
  provider    = vault.promptintel
  path        = "aws-vowel-genai-dev"
  description = "AWS Secrets Engine for CI access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-promptintel-dev.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-promptintel-dev.secret
}

resource "vault_aws_secret_backend_role" "jenkins-role" {
  provider        = vault.promptintel
  backend         = vault_aws_secret_backend.aws-promptintel-dev.path
  name            = "jenkins-role"
  credential_type = "assumed_role"

  role_arns = [
    data.aws_iam_role.jenkins-promptintel.arn,
  ]
}