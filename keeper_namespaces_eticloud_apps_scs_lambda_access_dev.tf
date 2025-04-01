# sscs-dev aws account
locals {
    dev_name = "sscs-dev"
}

data "vault_generic_secret" "aws_infra_credential_dev" {
    provider = vault.eticloud
    path     = "secret/infra/aws/sscs-dev/vault_aws_auth"
}

resource "vault_auth_backend" "vault_auth_backend_dev" {
    provider = vault.venture
    type = "aws"
    path = "aws-${local.dev_name}"
}

resource "vault_aws_auth_backend_client" "auth_backend_client_dev" {
    provider = vault.venture
    backend    = vault_auth_backend.vault_auth_backend_dev.path
    access_key = data.vault_generic_secret.aws_infra_credential_dev.data["AWS_ACCESS_KEY_ID"]
    secret_key = data.vault_generic_secret.aws_infra_credential_dev.data["AWS_SECRET_ACCESS_KEY"]
}

resource "vault_policy" "dev_policy_dev" {
    provider = vault.venture
    name   = "lambda-${local.dev_name}"
    policy = <<EOF
path "secret/sandbox/*" {
capabilities = ["list","read"]
}
path "secret/data/sandbox/*" {
capabilities = ["list","read"]
}
path "secret/dev/*" {
capabilities = ["list","read"]
}
path "secret/data/dev/*" {
capabilities = ["list","read"]
}
EOF
}

# # Lambda scm-events-lambda-router-role-sandbox
# resource "vault_aws_auth_backend_role" "scm-events-lambda-router-role-sandbox" {
#     provider = vault.venture
#     backend             = vault_auth_backend.vault_auth_backend_dev.path
#     role                = "scm-events-lambda-router-role-sandbox"
#     auth_type           = "iam"
#     bound_account_ids   = ["710476389780"]
#     bound_iam_role_arns = ["arn:aws:iam::710476389780:role/scm-events-lambda-router-role-sandbox"]
#     token_policies      = [vault_policy.dev_policy_dev.name]
# }

# resource "vault_aws_auth_backend_role" "sscm-events-lambda-router-role-dev-us-east-2" {
#     provider = vault.venture
#     backend             = vault_auth_backend.vault_auth_backend_dev.path
#     role                = "scm-events-lambda-router-role-dev"
#     auth_type           = "iam"
#     bound_account_ids   = ["710476389780"]
#     bound_iam_role_arns = ["arn:aws:iam::710476389780:role/scm-events-lambda-router-role-dev-us-east-2"]
#     token_policies      = [vault_policy.dev_policy_dev.name]
# }

# resource "vault_aws_auth_backend_role" "scm-accounts-onboard-notifier" {
#     provider = vault.venture
#     backend             = vault_auth_backend.vault_auth_backend_dev.path
#     role                = "scm-accounts-onboard-notifier"
#     auth_type           = "iam"
#     bound_account_ids   = ["710476389780"]
#     bound_iam_role_arns = ["arn:aws:iam::710476389780:role/scm-accounts-onboard-notifier-role-dev-us-east-2"]
#     token_policies      = [vault_policy.dev_policy_dev.name]
# }



# Due to bug https://github.com/hashicorp/terraform-provider-vault/issues/378
# Run it via CLI
# vault write auth/aws-sscs-dev/role/scm-events-lambda-router-role-sandbox \
#     auth_type=iam \
#     bound_iam_principal_arn="arn:aws:iam::710476389780:role/scm-events-lambda-router-role-sandbox" \
#     policies="lambda-sscs-dev" \
#     ttl=1h
# vault write auth/aws-sscs-dev/role/scm-events-lambda-router-role-dev-us-east-2 \
#     auth_type=iam \
#     bound_iam_principal_arn="arn:aws:iam::710476389780:role/scm-events-lambda-router-role-dev-us-east-2" \
#     policies="lambda-sscs-dev" \
#     ttl=1h
# vault write auth/aws-sscs-dev/role/scm-accounts-onboard-notifier \
#     auth_type=iam \
#     bound_iam_principal_arn="arn:aws:iam::710476389780:role/scm-accounts-onboard-notifier-role-dev-us-east-2" \
#     policies="lambda-sscs-dev" \
#     ttl=1h


# Lambda configuration
# https://developer.hashicorp.com/vault/docs/platform/aws/lambda-extension#step-2-option-b-install-the-extension-for-lambda-functions-packaged-in-container-images
# VAULT_AUTH_PROVIDER=aws-sscs-dev
# VAULT_ADDR=https://keeper.cisco.com
# VAULT_NAMESPACE=eticloud/apps/scs
# VAULT_AUTH_ROLE=scm-events-lambda-router-role-sandbox
# VAULT_SECRET_PATH=secret/data/sandbox/infra/global/iam