provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

# AWS credentails are the same of cwpp-dev vault secret (we deploy on same aws account)
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
  provider = vault.eticloud
}

data "vault_generic_secret" "cluster_certificate" {
  depends_on = [module.eks_all_in_one]
  provider   = vault.eticloud
  path       = "secret/infra/eks/${local.name}/certificate"
}

provider "aws" {
  alias      = "target"
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  #region     = local.region
  region = "us-east-2"
}