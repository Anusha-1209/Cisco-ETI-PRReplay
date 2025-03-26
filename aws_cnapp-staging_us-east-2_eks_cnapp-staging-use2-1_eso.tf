provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider    = vault.eticloud
  path        = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = local.region
}

data "aws_eks_cluster" "cluster" {
  depends_on = [ module.eks_all_in_one ]
  name      = local.name
}

data "vault_generic_secret" "cluster_certificate" {
  depends_on = [ module.eks_all_in_one ]
  provider = vault.eticloud
  path = "secret/infra/eks/${local.name}/certificate"
}

module "eso_eticloud" {
  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name         = local.name
  vault_namespace      = "eticloud"
  kubernetes_host      = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies             = ["external-secrets-staging"]
}

module "eso_eticloud_apps_securecn" {
  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name         = local.name
  vault_namespace      = "eticloud/apps/securecn"
  kubernetes_host      = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies             = ["external-secrets-${local.name}"]
}

module "eso_eticloud_apps_rosey" {
  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name         = local.name
  vault_namespace      = "eticloud/apps/rosey"
  kubernetes_host      = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies             = ["external-secrets-${local.name}"]
}

module "eso_eticloud_apps_policy" {
  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name         = local.name
  vault_namespace      = "eticloud/apps/policy"
  kubernetes_host      = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies             = ["external-secrets-${local.name}"]
}
