# This file was created by Outshift Platform Self-Service automation.
module "eks_all_in_one" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"

  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.0.0.0/16"          # VPC CIDR
  cluster_version  = "1.29"                 # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m6a.xlarge"] # EKS instance types
  min_size       = 1               # EKS node group min size
  max_size       = 5               # EKS node group max size
  desired_size   = 3               # EKS node group desired size

  # Karpenter
  create_karpenter_irsa = true # Create Karpenter IRSA
} 
