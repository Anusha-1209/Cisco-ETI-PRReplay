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
  source            = "git::https://github.com/cisco-eti/sre-tf-module-argo-cluster-enrollment?ref=0.1.1"
  eks_cluster_name  = local.name
  eks_cluster_host  = data.aws_eks_cluster.eks.endpoint
  eks_cluster_ca    = data.aws_eks_cluster.eks.certificate_authority[0].data
  eks_cluster_token = data.aws_eks_cluster_auth.eks.token

  argocd_cluster_host  = data.aws_eks_cluster.argocd.endpoint
  argocd_cluster_token = data.aws_eks_cluster_auth.argocd.token
  argocd_cluster_ca    = data.aws_eks_cluster.argocd.certificate_authority[0].data
  providers = {
    aws.eks    = aws.eks
    aws.argocd = aws.argocd
  }
}
