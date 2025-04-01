data "vault_generic_secret" "aws_argocd_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.argocd_aws_account}/terraform_admin"
}

provider "aws" {
  alias       = "argocd"
  access_key  = data.vault_generic_secret.aws_argocd_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_argocd_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2"
  max_retries = 3
}

module "argocd" {
  source              = "git::https://github.com/cisco-eti/sre-tf-module-argo-cluster-enrollment?ref=0.1.0"
  argocd_cluster_name = local.argocd_k8s_name
  eks_cluster_name    = local.name
  providers = {
    aws.eks    = aws.eks
    aws.argocd = aws.argocd
  }
}