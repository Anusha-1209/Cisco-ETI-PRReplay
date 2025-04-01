locals {
  aws_account        = "dragonfly-prod"
  role_name          = "ml-inferenceclient-role"
  role_description   = "IAM Role for inference client service"

  # AWS EKS Cluster
  cluster_name = "dragonfly-prod-1"
  oidc_id      = trimprefix(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")

  # AWS MSK Cluster
  dragonfly_msk_cluster_name = "dragonfly-msk-1"

  dragonfly_backend_namespace = "dragonfly-backend"
  service_account             = "${local.dragonfly_backend_namespace}:dragonfly-ml-inferenceclient-a-dev-app"
}
