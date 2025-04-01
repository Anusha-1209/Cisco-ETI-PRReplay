data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks_all_in_one]
  provider   = aws.target
  name       = local.name
}

data "vault_generic_secret" "cluster_certificate" {
  depends_on = [module.eks_all_in_one]
  provider   = vault.eticloud
  path       = "secret/infra/eks/${local.name}/certificate"
}

module "eso_eticloud" {
  source          = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name    = local.name
  vault_namespace = "eticloud"
  kubernetes_host = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca   = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies        = ["external-secrets-prod"]
}

