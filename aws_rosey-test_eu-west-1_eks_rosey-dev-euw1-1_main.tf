terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-nonprod"                                                   # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/rosey-test/eu-west-1/eks/rosey-dev-euw1-1.tfstate"       # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"                                                                   # DO NOT CHANGE.

  }
}

locals {
  name = "rosey-dev-euw1-1"
  region = "eu-west-1"
  aws_account_name = "rosey-test"
}

module "eks_all_in_one" {
  source            = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=0.0.5"

  name              = local.name              # EKS cluster name
  region            = local.region            # AWS provider region
  aws_account_name  = local.aws_account_name  # AWS account name
  cidr              = "10.0.0.0/16"           # VPC CIDR
  cluster_version   = "1.28"                  # EKS cluster version

  # EKS Managed Private Node Group
  instance_types    = ["m6a.2xlarge"]           # EKS instance types
  min_size          = 5                       # EKS node group min size
  max_size          = 10                      # EKS node group max size
  desired_size      = 5                       # EKS node group desired size
}
