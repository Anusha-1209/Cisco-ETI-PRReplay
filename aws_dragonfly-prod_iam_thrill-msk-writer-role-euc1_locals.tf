locals {
  aws_account      = "dragonfly-prod"
  aws_region       = "eu-central-1"
  role_name        = "dragonfly-prod-euc1-thrill-msk-writer-role"
  policy_name      = "dragonfly-prod-euc1-thrill-msk-writer-policy"
  role_description = "IAM Role for MSK access for Dragonfly Thrill"

  # AWS EKS Cluster
  cluster_name = "dragonfly-prod-euc1-1"
  oidc_id      = trimprefix(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")

  # AWS MSK cluster
  msk_cluster_name = "dragonfly-msk-prod-eu1"

  dragonfly_backend_namespace = "dragonfly-backend"
  service_account             = "${local.dragonfly_backend_namespace}:dragonfly-thrill-argo"
}
