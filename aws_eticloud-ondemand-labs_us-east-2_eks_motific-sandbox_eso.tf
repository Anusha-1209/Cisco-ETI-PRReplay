# This file was created by Outshift Platform Self-Service automation.
data "vault_generic_secret" "cluster_certificate" {
  path       = "secret/infra/eks/${local.name}/certificate"
  depends_on = [module.eks_all_in_one]
}

module "eso_eticloud" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"

  cluster_name    = local.name
  vault_namespace = "eticloud"
  kubernetes_host = data.aws_eks_cluster.eks.endpoint
  kubernetes_ca   = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies        = ["external-secrets-dev"]
}
resource "vault_policy" "demo-labs" {
  name     = "external-secrets-${local.name}"
  provider = vault.apps_apisec
  policy   = <<EOT
    # K8s External Secrets Vault Policy

    # dev secrets
    path "secret/data/dev/*" {
      capabilities = ["read", "list"]
    }
    path "secret/dev/*" {
      capabilities = ["read", "list"]
    }
    path "dev/*" {
      capabilities = ["read", "list"]
    }
    path "dev/data/*" {
      capabilities = ["read", "list"]
    }
EOT
}
module "eso_eticloud_apps_demo-labs" {
  source               = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name         = local.name
  vault_namespace      = "eticloud/apps/demo-labs"
  kubernetes_host      = data.aws_eks_cluster.eks.endpoint
  kubernetes_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies             = [vault_policy.marvin-apps.name]
}
