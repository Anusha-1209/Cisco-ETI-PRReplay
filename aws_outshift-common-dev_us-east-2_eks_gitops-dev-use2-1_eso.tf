locals {
  policy_eticloud = <<-EOT
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

  # Prod External DNS
  path "secret/data/prod/route53-prod-external-DNS" {
    capabilities = ["read", "list"]
  }
  EOT
}

# cluster resources for external-secrets
module "eso_eticloud" {
  depends_on = [ module.eks_all_in_one ]
  cluster_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  cluster_endpoint  = data.vault_generic_secret.cluster_endpoint.data["cluster_endpoint"]
  cluster_name      = local.name
  environment       = local.environment
  policy            = local.policy_eticloud
  source            = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=2.0.7"
  vault_namespace   = "eticloud"
  
  providers = {
    vault      = vault.eticloud
  }
}