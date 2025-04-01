# sscs-staging aws account
locals {
    staging_name = "sscs-staging"
}

data "vault_generic_secret" "aws_infra_credential_staging" {
    provider = vault.eticloud
    path     = "secret/infra/aws/sscs-staging/vault_aws_auth"
}

resource "vault_auth_backend" "vault_auth_backend_staging" {
    provider = vault.venture
    type = "aws"
    path = "aws-${local.staging_name}"
}

resource "vault_aws_auth_backend_client" "auth_backend_client_staging" {
    provider = vault.venture
    backend    = vault_auth_backend.vault_auth_backend_staging.path
    access_key = data.vault_generic_secret.aws_infra_credential_staging.data["AWS_ACCESS_KEY_ID"]
    secret_key = data.vault_generic_secret.aws_infra_credential_staging.data["AWS_SECRET_ACCESS_KEY"]
}

resource "vault_policy" "staging_policy_staging" {
    provider = vault.venture
    name   = "lambda-${local.staging_name}"
    policy = <<EOF
path "secret/staging/*" {
capabilities = ["list","read"]
}
path "secret/data/staging/*" {
capabilities = ["list","read"]
}
EOF
}

# # Lambda scm-events-lambda-router-role-sandbox
# resource "vault_aws_auth_backend_role" "scm-events-lambda-router-role-sandbox" {
#     provider = vault.venture
#     backend             = vault_auth_backend.vault_auth_backend_staging.path
#     role                = "scm-events-lambda-router-role-sandbox"
#     auth_type           = "iam"
#     bound_account_ids   = ["710476389780"]
#     bound_iam_role_arns = ["arn:aws:iam::710476389780:role/scm-events-lambda-router-role-sandbox"]
#     inferred_aws_region = "us-east-2" # Bug https://github.com/hashicorp/terraform-provider-vault/issues/378
#     inferred_entity_type = "iam"
#     token_policies      = [vault_policy.staging_policy.name]
# }
# Due to bug https://github.com/hashicorp/terraform-provider-vault/issues/378
# Run it via CLI
# vault write auth/aws-sscs-staging/role/scm-events-lambda-router-role-staging-us-east-2 \
#     auth_type=iam \
#     bound_iam_principal_arn="arn:aws:iam::127494549027:role/scm-events-lambda-router-role-staging-us-east-2" \
#     policies="lambda-sscs-staging" \
#     ttl=1h



# Lambda configuration
# https://stagingeloper.hashicorp.com/vault/docs/platform/aws/lambda-extension#step-2-option-b-install-the-extension-for-lambda-functions-packaged-in-container-images
# VAULT_AUTH_PROVIDER=aws-sscs-staging
# VAULT_ADDR=https://keeper.cisco.com
# VAULT_NAMESPACE=eticloud/apps/scs
# VAULT_AUTH_ROLE=scm-events-lambda-router-role-sandbox
# VAULT_SECRET_PATH=secret/data/sandbox/infra/global/iam