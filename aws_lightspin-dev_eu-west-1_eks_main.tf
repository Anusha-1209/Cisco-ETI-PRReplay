module "eks_all_in_one" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=0.5.7"
  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.eks_aws_account_name # AWS account name
  cidr             = "10.0.0.0/16"          # VPC CIDR
  private_subnet_bits = 2                  # Private subnet bits
  cluster_version  = "1.29"                 # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m6a.2xlarge"] # EKS instance types
  min_size       = 5               # EKS node group min size
  max_size       = 15              # EKS node group max size
  desired_size   = 8               # EKS node group desired size

  # Karpenter
  create_karpenter_irsa = true # Create Karpenter IRSA
}
