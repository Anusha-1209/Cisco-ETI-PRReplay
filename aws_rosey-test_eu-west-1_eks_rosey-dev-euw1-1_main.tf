terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-nonprod"                                                   # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/rosey-test/eu-west-1/eks/rosey-dev-euw1-1.tfstate" # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"                                                                   # DO NOT CHANGE.

  }
}

module "eks_all_in_one" {
  source            = "../../../../../modules/eks_all_in_one"
  name              = "rosey-dev-euw1-1"        # EKS cluster name
  region            = "eu-west-1"             # AWS provider region
  aws_account_name  = "rosey-test"    # AWS account name
  cidr              = "10.59.0.0/16"          # VPC CIDR
  cluster_version   = "1.28"                  # EKS cluster version

  # EKS Managed Private Node Group
  instance_types    = ["m6a.large"]           # EKS instance types
  min_size          = 2                       # EKS node group min size
  max_size          = 10                      # EKS node group max size
  desired_size      = 2                       # EKS node group desired size
}