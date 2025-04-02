locals {
  aws_account        = "dragonfly-prod"
  role_name          = "dragonfly-event-manager-role-use2"
  role_description   = "IAM Role for dragonfly-event-manager"

  dragonfly_msk_cluster_name = "dragonfly-msk-prod-1"

  # AWS EKS Cluster
  cluster_name = "dragonfly-prod-1"
  oidc_id      = trimprefix(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")

  dragonfly_backend_namespace = "dragonfly-backend"
  service_account             = "${local.dragonfly_backend_namespace}:dragonfly-event-manager-service-account"
}
