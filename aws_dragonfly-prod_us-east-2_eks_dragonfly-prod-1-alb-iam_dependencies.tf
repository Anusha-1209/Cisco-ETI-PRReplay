data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/dragonfly-production/aws"
  provider = vault.eticloud_eticcprod
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}
