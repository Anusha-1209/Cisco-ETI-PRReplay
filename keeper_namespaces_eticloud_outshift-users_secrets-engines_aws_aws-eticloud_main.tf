resource "vault_aws_secret_backend" "dev-sandbox-aws-eticloud" {
  provider    = vault.outshift-users
  path        = "dev-sandbox-aws-eticloud"
  description = "AWS Secrets Engine for Dev Sandbox access"

  access_key  = aws_iam_access_key.vault-secret-engine-dev-sandbox.id
  secret_key  = aws_iam_access_key.vault-secret-engine-dev-sandbox.secret
}

resource "vault_aws_secret_backend_role" "dev-sandbox-vault-role" {
  provider        = vault.outshift-users
  backend         = vault_aws_secret_backend.dev-sandbox-aws-eticloud.path
  name            = "dev-sandbox-vault-role"
  credential_type = "iam_user"

  policy_document = aws_iam_policy.dev-sandbox-ecr-access-policy.policy
}