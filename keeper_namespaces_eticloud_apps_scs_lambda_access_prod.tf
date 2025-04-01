# sscs-prod aws account
locals {
    prod_name = "sscs-prod"
}

data "vault_generic_secret" "aws_infra_credential_prod" {
    provider = vault.eticloud
    path     = "secret/infra/aws/sscs-prod/vault_aws_auth"
}

resource "vault_auth_backend" "vault_auth_backend_prod" {
    provider = vault.venture
    type = "aws"
    path = "aws-${local.prod_name}"
}

resource "vault_aws_auth_backend_client" "auth_backend_client_prod" {
    provider = vault.venture
    backend    = vault_auth_backend.vault_auth_backend_prod.path
    access_key = data.vault_generic_secret.aws_infra_credential_prod.data["AWS_ACCESS_KEY_ID"]
    secret_key = data.vault_generic_secret.aws_infra_credential_prod.data["AWS_SECRET_ACCESS_KEY"]
}

resource "vault_policy" "prod_policy_prod" {
    provider = vault.venture
    name   = "lambda-${local.prod_name}"
    policy = <<EOF
path "secret/prod/*" {
capabilities = ["list","read"]
}
path "secret/data/prod/*" {
capabilities = ["list","read"]
}
EOF
}


# resource "vault_aws_auth_backend_role" "scm-events-lambda-router-role-prod-us" {
#     provider = vault.venture
#     backend             = vault_auth_backend.vault_auth_backend_dev.path
#     role                = "scm-events-lambda-router-role-prod-us"
#     auth_type           = "iam"
#     bound_account_ids   = ["105928782844"]
#     bound_iam_role_arns = ["arn:aws:iam::105928782844:role/scm-events-lambda-router-role-prod-us-east-2"]
#     token_policies      = [vault_policy.prod_policy_prod.name]
# }

# resource "vault_aws_auth_backend_role" "scm-events-lambda-router-role-prod-eu" {
#     provider = vault.venture
#     backend             = vault_auth_backend.vault_auth_backend_dev.path
#     role                = "scm-events-lambda-router-role-prod-eu"
#     auth_type           = "iam"
#     bound_account_ids   = ["1059287828440"]
#     bound_iam_role_arns = ["arn:aws:iam::105928782844:role/scm-events-lambda-router-role-prod-eu-central-1"]
#     token_policies      = [vault_policy.prod_policy_prod.name]
# }


# # Lambda scm-events-lambda-router-role-sandbox
# resource "vault_aws_auth_backend_role" "scm-events-lambda-router-role-sandbox" {
#     provider = vault.venture
#     backend             = vault_auth_backend.vault_auth_backend_prod.path
#     role                = "scm-events-lambda-router-role-sandbox"
#     auth_type           = "iam"
#     bound_account_ids   = ["710476389780"]
#     bound_iam_role_arns = ["arn:aws:iam::710476389780:role/scm-events-lambda-router-role-sandbox"]
#     inferred_aws_region = "us-east-2" # Bug https://github.com/hashicorp/terraform-provider-vault/issues/378
#     inferred_entity_type = "iam"
#     token_policies      = [vault_policy.prod_policy.name]
# }
# Due to bug https://github.com/hashicorp/terraform-provider-vault/issues/378
# Run it via CLI
# vault write auth/aws-sscs-prod/role/scm-events-lambda-router-role-prod-us-east-2 \
#     auth_type=iam \
#     bound_iam_principal_arn="arn:aws:iam::105928782844:role/scm-events-lambda-router-role-prod-us-east-2" \
#     policies="lambda-sscs-prod" \
#     ttl=1h
# vault write auth/aws-sscs-prod/role/scm-events-lambda-router-role-prod-eu-central-1 \
#     auth_type=iam \
#     bound_iam_principal_arn="arn:aws:iam::105928782844:role/scm-events-lambda-router-role-prod-eu-central-1" \
#     policies="lambda-sscs-prod" \
#     ttl=1h


# Lambda configuration
# https://prodeloper.hashicorp.com/vault/docs/platform/aws/lambda-extension#step-2-option-b-install-the-extension-for-lambda-functions-packaged-in-container-images
# VAULT_AUTH_PROVIDER=aws-sscs-prod
# VAULT_ADDR=https://keeper.cisco.com
# VAULT_NAMESPACE=eticloud/apps/scs
# VAULT_AUTH_ROLE=scm-events-lambda-router-role-sandbox
# VAULT_SECRET_PATH=secret/data/sandbox/infra/global/iam