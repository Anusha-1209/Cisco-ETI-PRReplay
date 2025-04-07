locals {
  policy_a3po = <<-EOT
  # K8s External Secrets Vault Policy

  # Secret paths
  path "secret/data/dev/*" {
    capabilities = ["read", "list"]
  }
  path "secret/dev/*" {
    capabilities = ["read", "list"]
  }

  # Common secrets
  path "secret/data/common/*" {
    capabilities = ["read", "list"]
  }
  path "secret/common/*" {
    capabilities = ["read", "list"]
  }
  EOT
}

provider "vault" {
  alias     = "a3po"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/a3po"
}

# cluster resources for external-secrets
module "eso_a3po" {
  depends_on = [ module.eks_all_in_one ]
  cluster_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  cluster_endpoint  = data.vault_generic_secret.cluster_endpoint.data["cluster_endpoint"]
  cluster_name      = local.name
  environment       = local.environment
  policy            = local.policy_a3po
  source            = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=2.0.7"
  vault_namespace   = "eticloud/apps/a3po"
  
  providers = {
    vault      = vault.a3po
  }
}