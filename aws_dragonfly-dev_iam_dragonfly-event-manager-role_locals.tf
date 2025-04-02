locals {
  aws_account        = "dragonfly-dev"
  role_name          = "dragonfly-event-manager-role"
  role_description   = "IAM Role for dragonfly-event-manager"

  dragonfly_msk_cluster_name = "dragonfly-msk-1"

  # AWS EKS Cluster
  cluster_name = "eks-dragonfly-dev-2"
  oidc_id      = trimprefix(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")

  dragonfly_backend_namespace = "dragonfly-backend"
  service_account             = "${local.dragonfly_backend_namespace}:dragonfly-event-manager-service-account"
}
