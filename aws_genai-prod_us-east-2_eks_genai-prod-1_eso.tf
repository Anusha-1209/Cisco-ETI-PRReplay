provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = local.region
}

data "aws_eks_cluster" "cluster" {
  name       = local.name
  depends_on = [module.eks_all_in_one]
}

data "vault_generic_secret" "cluster_certificate" {
  path       = "secret/infra/eks/${local.name}/certificate"
  depends_on = [module.eks_all_in_one]
}

module "eso_eticloud" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"

  cluster_name    = local.name
  vault_namespace = "eticloud"
  kubernetes_host = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca   = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies        = ["external-secrets-prod"]
}

resource "vault_policy" "ppu-apps" {
  name     = "external-secrets-${local.name}"
  provider = vault.eticloud
  policy   = <<EOT
    # K8s External Secrets Vault Policy

    # Prod secrets
    path "secret/data/prod/*" {
      capabilities = ["read", "list"]
    }
    path "secret/prod/*" {
      capabilities = ["read", "list"]
    }
    path "prod/*" {
      capabilities = ["read", "list"]
    }
    path "prod/data/*" {
      capabilities = ["read", "list"]
    }
EOT
}

module "eso_eticloud_apps_ppu" {
  source          = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name    = local.name
  vault_namespace = "eticloud/apps/ppu"
  kubernetes_host = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca   = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies        = ["external-secrets-${local.name}"]
}
