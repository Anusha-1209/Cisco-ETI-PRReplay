resource "vault_aws_secret_backend" "aws-vowel-genai-dev" {
  provider    = vault.vowel
  path        = "aws-vowel-genai-dev"
  description = "AWS Secrets Engine for CI access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-vowel-genai-dev.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-vowel-genai-dev.secret
}

resource "vault_aws_secret_backend_role" "jenkins-role" {
  provider        = vault.vowel
  backend         = vault_aws_secret_backend.aws-vowel-genai-dev.path
  name            = "jenkins-role"
  credential_type = "assumed_role"

  role_arns = [
    aws_iam_role.jenkins.arn,
  ]
}