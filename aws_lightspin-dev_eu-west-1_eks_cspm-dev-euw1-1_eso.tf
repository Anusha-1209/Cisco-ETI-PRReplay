module "eso_eticloud" {
  source          = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name    = local.name
  vault_namespace = "eticloud"
  kubernetes_host = data.aws_eks_cluster.eks.endpoint
  kubernetes_ca   = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  policies        = ["external-secrets"]
}

module "eso_eticloud_apps_lightspin" {
  source          = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name    = local.name
  vault_namespace = "eticloud/apps/lightspin"
  kubernetes_host = data.aws_eks_cluster.eks.endpoint
  kubernetes_ca   = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  policies        = ["external-secrets"]
}

module "eso_apps_sre" {
  source          = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name    = local.name
  vault_namespace = "eticloud/apps/sre"
  kubernetes_host = data.aws_eks_cluster.eks.endpoint
  kubernetes_ca   = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  policies        = ["external-secrets"]
}