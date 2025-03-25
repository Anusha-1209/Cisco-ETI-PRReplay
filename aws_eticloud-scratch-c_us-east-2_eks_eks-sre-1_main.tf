terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod" # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/eticloud-scratch-c/us-east-2/eks/eks-sre-1.tfstate" # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.
  }
}

locals {
  name             = "eks-sre-1"
  region           = "us-east-2"
  aws_account_name = "eticloud-scratch-c"
  vpc_cidr         = "10.0.0.0/16"
}

module "eks_all_in_one" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest" # Based on v0.0.10
  name             = local.name                                                                    # EKS cluster name
  region           = local.region                                                                  # AWS provider region
  aws_account_name = local.aws_account_name                                                        # AWS account name
  cidr             = local.vpc_cidr                                                                # VPC CIDR
  cluster_version  = "1.29"                                                                        # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m6a.large"] # EKS instance types
  min_size       = 3             # EKS node group min size
  max_size       = 5             # EKS node group max size
  desired_size   = 3             # EKS node group desired size
}
