terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key = "terraform-state/aws/motific-prod/us-east-2/eks/motf-prod-usw2-1.tfstate"
    region = "us-east-2"
  }
}

locals {
  name             = "motf-prod-usw2-1"
  region           = "us-west-2"
  aws_account_name = "motific-prod"
}

module "eks_all_in_one" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"
  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.3.0.0/16"          # VPC CIDR
  cluster_version  = "1.28"                 # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m6a.2xlarge"]          # EKS instance types
  min_size       = 2                        # EKS node group min size
  max_size       = 15                       # EKS node group max size
  desired_size   = 2                        # EKS node group desired size
  allow_eks_api_internet_access = false     # Allow EKS API internet access

  # Karpenter is setup by default
  # create_karpenter_irsa = true              # Create Karpenter IRSA
}
