module "eso_eticloud_apps_ostinato" {
  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name         = local.name
  vault_namespace      = "eticloud/apps/ostinato"
  kubernetes_host      = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies             = ["external-secrets-${local.name}"]
}
