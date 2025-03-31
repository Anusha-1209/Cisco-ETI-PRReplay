resource "vault_aws_secret_backend" "ci-aws-eticloud-scratch" {
  provider    = vault.eticloud
  path        = "ci-aws-eticloud-scratch"
  description = "AWS Secrets Engine for CI-related access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-eticloud-scratch.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-eticloud-scratch.secret
}


resource "vault_aws_secret_backend_role" "eticloud-scratch-ci-role" {
  provider        = vault.eticloud
  backend         = vault_aws_secret_backend.ci-aws-eticloud-scratch.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.ci-default-role.arn,
    "arn:aws:iam::380642323071:role/gbear"
  ]
}