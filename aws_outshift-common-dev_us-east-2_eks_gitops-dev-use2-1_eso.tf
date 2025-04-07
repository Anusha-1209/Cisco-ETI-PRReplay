# This file was created by Outshift Platform Self-Service automation.
data "vault_generic_secret" "cluster_certificate" {
  path       = "secret/infra/eks/${local.name}/certificate"
  depends_on = [module.eks_all_in_one]
}

locals {
  policy = <<-EOT
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

module "eso_eticloud" {
  source          = "git::https://github.com/cisco-eti/sre-tf-module-eso-access.git?ref=2.0.6"
  cluster_name      = local.name
  vault_namespace   = "eticloud"
  cluster_endpoint  = data.aws_eks_cluster.eks.endpoint
  cluster_ca        = base64decode(data.vault_generic_secret.cluster_certificate.data["b64certificate"])
  policy            = local.policy
  environment       = local.environment
  
  providers = {
    aws = aws.eks
  }
}
