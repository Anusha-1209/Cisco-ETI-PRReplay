############### STEP 2: AWS Vault Secret Engine Configuration ###################
resource "vault_aws_secret_backend" "aws_lightspin_staging_backend" {
  provider    = vault.venture
  path        = "aws-lightspin-staging"
  description = "AWS Secrets Engine for lightspin staging SQS resource accesss"

  access_key = aws_iam_access_key.vault_secrets_engine_user_credentials.id
  secret_key = aws_iam_access_key.vault_secrets_engine_user_credentials.secret
}

resource "vault_aws_secret_backend_role" "aws_lightspin_staging_backend_role" {
  provider        = vault.venture
  backend         = vault_aws_secret_backend.aws_lightspin_staging_backend.path
  name            = "lightspin-staging-vault-role"
  credential_type = "assumed_role"

  role_arns = [ 
    aws_iam_role.sqs_lightspin_staging_role.arn
   ]
}