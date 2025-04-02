resource "vault_aws_secret_backend" "ci-aws-eti-ci" {
  provider    = vault.eticloud
  path        = "ci-aws-eti-ci"
  description = "AWS Secrets Engine for CI-related access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-ci.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-ci.secret
}

resource "vault_aws_secret_backend_role" "ci-vault-role" {
  provider        = vault.eticloud
  backend         = vault_aws_secret_backend.ci-aws-eti-ci.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"

  #TODO: replace with narrow-scope role arn
  role_arns       = ["arn:aws:iam::009736724745:role/jenkins-ec2-readonly"]
}

