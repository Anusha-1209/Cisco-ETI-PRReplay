provider "aws" {
  alias       = "argocd"
  access_key  = data.vault_generic_secret.aws_argocd_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_argocd_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}
