locals {
  policy_ostinato = <<-EOT
  # K8s External Secrets Vault Policy

  # Secret paths
  path "secret/data/prod/*" {
    capabilities = ["read", "list"]
  }
  path "secret/prod/*" {
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
  alias     = "ostinato"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/apps/ostinato"
}

# cluster resources for external-secrets
module "eso_ostinato" {
  depends_on = [ module.eks_all_in_one ]
  cluster_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  cluster_endpoint  = data.vault_generic_secret.cluster_endpoint.data["cluster_endpoint"]
  cluster_name      = local.name
  environment       = local.environment
  policy            = local.policy_ostinato
  source            = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=2.0.7"
  vault_namespace   = "eticloud/apps/ostinato"
  
  providers = {
    vault      = vault.ostinato
  }
}