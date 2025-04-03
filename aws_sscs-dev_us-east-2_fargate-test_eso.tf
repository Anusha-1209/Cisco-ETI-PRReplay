module "eso_eticloud" {
  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=0.0.2"

  cluster_name         = var.eks_name
  vault_namespace      = "eticloud"
  kubernetes_host      = module.eks.cluster_endpoint
  kubernetes_ca        = base64decode(module.eks.cluster_certificate_authority_data)
  policies             = ["external-secrets-dev"]
}
