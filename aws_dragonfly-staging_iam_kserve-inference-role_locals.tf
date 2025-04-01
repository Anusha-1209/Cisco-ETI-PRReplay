locals {
  aws_account        = "dragonfly-staging"
  role_name          = "dragonfly-kserve-inference-role"
  role_description   = "IAM Role for kserve inference service"

  # AWS EKS Cluster
  cluster_name = "eks-df-staging-1"
  oidc_id      = trimprefix(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://")

  dragonfly_backend_namespace = "dragonfly-backend"
  service_account             = "${local.dragonfly_backend_namespace}:dragonfly-ml-inferenceserver"
}
