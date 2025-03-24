module "eticloud_setup_external_secrets_operator" {
  for_each = { for key, value in var.external_secrets_namespaces : key => value if var.var.setup_external_secrets_operator }

  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=0.0.2"
  cluster_name         = local.name
  vault_namespace      = each.key
  kubernetes_host      = cluster_endpoint
  kubernetes_ca        = local.cluster_auth_base64
  policies             = each.value.vault_policy

  depends_on = [
    aws_eks_node_group.eks_managed_node_group
  ]
}