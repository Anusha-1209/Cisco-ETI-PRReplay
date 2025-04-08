data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

data "vault_generic_secret" "cluster_certificate" {
  provider = vault.eticloud
  path     = "secret/infra/eks/${local.cluster_name}/certificate"
}

data "vault_generic_secret" "cluster_endpoint" {
  provider = vault.eticloud
  path     = "secret/infra/eks/${local.cluster_name}/cluster_endpoint"
}

data "aws_eks_cluster" "cluster" {
  name = "comn-dev-use2-1"
}
