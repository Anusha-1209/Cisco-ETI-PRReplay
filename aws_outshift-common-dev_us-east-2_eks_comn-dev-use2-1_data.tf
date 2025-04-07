data "vault_generic_secret" "cluster_endpoint" {
  depends_on = [module.eks_all_in_one]
  path       = "secret/infra/eks/${local.name}/cluster_endpoint"
}