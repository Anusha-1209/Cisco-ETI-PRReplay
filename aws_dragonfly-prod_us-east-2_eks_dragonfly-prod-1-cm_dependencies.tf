data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/dragonfly-prod/terraform_admin"
  provider = vault.eticloud
}

data "vault_generic_secret" "cluster_certificate" {
  path     = "secret/infra/eks/dragonfly-prod-1/certificate"
  provider = vault.eticloud
}

data "vault_generic_secret" "aws_auth_configmap" {
  path     = "secret/infra/eks/dragonfly-prod-1/aws-auth"
  provider = vault.eticloud
}

data "aws_eks_cluster" "cluster" {
  name = "dragonfly-prod-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "dragonfly-prod-1"
}
