resource "vault_aws_secret_backend" "ci-aws-eticloud-preproduction" {
  provider    = vault.eticloud
  path        = "ci-aws-eticloud-preproduction"
  description = "AWS Secrets Engine for CI-related access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-eticloud-preproduction.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-eticloud-preproduction.secret
}


resource "vault_aws_secret_backend_role" "eticloud-preproduction-ci-role" {
  provider        = vault.eticloud
  backend         = vault_aws_secret_backend.ci-aws-eticloud-preproduction.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.ci-default-role.arn
  ]
}

resource "vault_aws_secret_backend_role" "eticloud-preproduction-greatbear-ci-role" {
  provider        = vault.eticloud
  backend         = vault_aws_secret_backend.ci-aws-eticloud-preproduction.path
  name            = "greatbear-ci-vault-role"
  credential_type = "assumed_role"
  role_arns       = [
    aws_iam_role.eticloud-preproduction-greatbear-ci-role.arn
  ]
}