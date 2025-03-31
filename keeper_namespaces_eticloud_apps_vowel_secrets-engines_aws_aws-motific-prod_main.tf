resource "vault_aws_secret_backend" "aws-motific-prod" {
  provider    = vault.vowel
  path        = "aws-motific-prod"
  description = "AWS Secrets Engine for CI access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-motific-prod.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-motific-prod.secret
}

resource "vault_aws_secret_backend_role" "jenkins-role" {
  provider        = vault.vowel
  backend         = vault_aws_secret_backend.aws-motific-prod.path
  name            = "jenkins-role"
  credential_type = "assumed_role"

  role_arns = [
    aws_iam_role.jenkins.arn,
  ]
}