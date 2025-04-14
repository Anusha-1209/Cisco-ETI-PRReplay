terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-prod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/dragonfly-demo/eu-west-1/eks/dragonfly-tgt-euw1-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.
  }
}

locals {
  name             = "dragonfly-tgt-euw1-1"
  region           = "eu-west-1"
  aws_account_name = "dragonfly-demo"
}

module "eks_all_in_one" {
  # EKS cluster partially created as of Jan 15 2024
  source = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=extend_ami" # Based on v0.0.10

  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.4.0.0/16"          # VPC CIDR
  cluster_version  = "1.28"                 # EKS cluster version

  # EKS Managed Private Node Group
  hardened_image               = false           # Use or not cisco hardened images
  ami_type                     = "AL2_x86_64"    # EKS AMI type, required in case non hardened images
    enable_bootstrap_user_data = false           # Disable user data bootrap for non hardened images
  instance_types               = ["m5a.2xlarge"] # EKS instance types, prod US uses m5a.2xlarge
  min_size                     = 2               # EKS node group min size
  max_size                     = 5               # EKS node group max size
  desired_size                 = 2               # EKS node group desired size
}
