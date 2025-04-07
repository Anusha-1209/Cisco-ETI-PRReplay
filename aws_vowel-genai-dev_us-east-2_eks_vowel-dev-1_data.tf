data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = local.eks_name
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

data "vault_generic_secret" "cluster_certificate" {
  provider   = vault.eticloud
  path       = "secret/infra/eks/${local.name}/certificate"
}

