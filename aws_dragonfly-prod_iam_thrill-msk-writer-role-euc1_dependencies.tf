data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

data "aws_msk_cluster" "dragonfly_msk_euc_1" {
  cluster_name = local.msk_cluster_name
}
