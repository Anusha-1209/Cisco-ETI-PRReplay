resource "vault_aws_secret_backend" "ci-aws-eticloud" {
  provider    = vault.eticloud
  path        = "ci-aws-eticloud"
  description = "AWS Secrets Engine for CI-related access"

  access_key  = aws_iam_access_key.vault-secret-engine-user-eticloud.id
  secret_key  = aws_iam_access_key.vault-secret-engine-user-eticloud.secret
}

resource "vault_aws_secret_backend_role" "ci-vault-role" {
  provider        = vault.eticloud
  backend         = vault_aws_secret_backend.ci-aws-eticloud.path
  name            = "ci-vault-role"
  credential_type = "assumed_role"

  role_arns = [
    aws_iam_role.ci-ecr-push.arn,
    aws_iam_role.ci-helm-push.arn,
    aws_iam_role.ci-default.arn,
    aws_iam_role.ci-s3-bucket.arn,
    "arn:aws:iam::626007623524:role/great-bear" 
  ]
}

resource "vault_aws_secret_backend_role" "eticloud-sre-audit-ro" {
  provider        = vault.eticloud
  backend         = vault_aws_secret_backend.ci-aws-eticloud.path
  name            = "eticloud-sre-audit-ro"
  credential_type = "assumed_role"
  role_arns       = ["arn:aws:iam::626007623524:role/sre-audit-ro"]
}
