data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-prod/terraform_admin"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_caller_identity" "current" {}
