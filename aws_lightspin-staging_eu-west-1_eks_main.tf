terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-prod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/lightspin-staging/eu-west-1/eks/lightspin-staging-use2-1.tfstate"# UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.

  }
}

locals {
  name             = "cspm-staging-euw1-1"
  region           = "eu-west-1"
  aws_account_name = "lightspin-staging"
}

module "eks_all_in_one" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=0.5.7"
  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
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
