terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key = "terraform-state/aws/motific-prod/us-east-2/eks/motf-prod-use2-1.tfstate"
    region = "us-east-2"
  }
}

locals {
  name             = "motf-prod-use2-1"
  region           = "us-east-2"
  aws_account_name = "motific-prod"
}

module "eks_all_in_one" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"
  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.1.0.0/16"          # VPC CIDR
  cluster_version  = "1.28"                 # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m6a.2xlarge"] # EKS instance types
  min_size       = 8               # EKS node group min size
  max_size       = 15              # EKS node group max size
  desired_size   = 8               # EKS node group desired size

  # Karpenter
  create_karpenter_irsa = true # Create Karpenter IRSA
}
