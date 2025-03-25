provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

provider "vault" {
  alias     = "eticloud/apps/websites"
  address   = "https://keeper.cisco.com"
  namespace = "websites"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticloud
  path     = "secret/infra/aws/${local.aws_account_name}/terraform_admin"
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = local.region
}

data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks_all_in_one]
  name       = local.name
}

data "vault_generic_secret" "cluster_certificate" {
  depends_on = [module.eks_all_in_one]
  provider   = vault.eticloud
  path       = "secret/infra/eks/${local.name}/certificate"
}

module "eso_eticloud" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"

  cluster_name    = local.name
  vault_namespace = "eticloud"
  kubernetes_host = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca   = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies        = ["external-secrets-staging"]
}
module "eso_eticloud_apps_websites" {
  source          = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=1.0.0"
  cluster_name    = local.name
  vault_namespace = "eticloud/apps/websites"
  kubernetes_host = data.aws_eks_cluster.cluster.endpoint
  kubernetes_ca   = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policies        = [vault_policy.policy-apps.name]
}

resource "vault_policy" "policy-apps" {
  name = "external-secrets-staging-websites"
  provider = vault.websites
  policy = <<EOT
    # K8s External Secrets Vault Policy

    # Dev secrets
    path "secret/data/dev/*" {
      capabilities = ["read", "list"]
    }
    path "secret/dev/*" {
      capabilities = ["read", "list"]
    }
    path "secret/data/staging/*" {
      capabilities = ["read", "list"]
    }
    path "secret/staging/*" {
      capabilities = ["read", "list"]
    }
    # Atlantis
    path "secret/data/atlantis/*" {
      capabilities = ["read", "list"]
    }
    path "secret/atlantis/*" {
      capabilities = ["read", "list"]
    }
    path "secret/data/keeper-atlantis/*" {
      capabilities = ["read", "list"]
    }
    path "secret/keeper-atlantis/*" {
      capabilities = ["read", "list"]
    }

    # Common secrets
    path "secret/data/common/*" {
      capabilities = ["read", "list"]
    }
    path "secret/common/*" {
      capabilities = ["read", "list"]
    }

    # Panoptica secrets
    path "secret/data/panoptica/staging/*" {
      capabilities = ["read", "list"]
    }
    path "secret/panoptica/staging/*" {
      capabilities = ["read", "list"]
    }
    
    # STO Secrets
    path "secret/data/sto/*" {
      capabilities = ["read", "list"]
    }
    path "secret/sto/*" {
      capabilities = ["read", "list"]
    }

    # Grafana Secrets
    path "secret/data/grafana/*" {
      capabilities = ["read", "list"]
    }
    path "secret/grafana/*" {
      capabilities = ["read", "list"]
    }

    # Harbor secrets
    path "secret/data/harbor/harbor-staging/*" {
      capabilities = ["read", "list"]
    }
    path "secret/harbor/harbor-staging/*" {
      capabilities = ["read", "list"]
    }

    # One-eye secrets
    path "secret/data/one-eye/*" {
      capabilities = ["read", "list"]
    }
    path "secret/one-eye/*" {
      capabilities = ["read", "list"]
    }

    # MSK secrets
    path "secret/data/infra/msk/*" {
      capabilities = ["read", "list"]
    }
    path "secret/infra/msk/*" {
      capabilities = ["read", "list"]
    }
    # GRAFANA secrets
    path "secret/data/grafana/*" {
      capabilities = ["read", "list"]
    }
    path "secret/grafana/*" {
      capabilities = ["read", "list"]
    }

EOT
} 