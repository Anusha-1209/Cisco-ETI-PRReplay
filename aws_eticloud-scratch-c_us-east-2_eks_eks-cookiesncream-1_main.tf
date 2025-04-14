terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-nonprod"                                                   # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/eticloud-scratch-c/us-east-2/eks/eks-cookiesncream-1.tfstate" # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"                                                                   # DO NOT CHANGE.

  }
}

locals {
  name              = "eks-cookiesncream-1"
  region            = "us-east-2"
  aws_account_name  = "eticloud-scratch-c"
  vpc_cidr          = "10.22.0.0/16"
}

module "eks_all_in_one" {
  source            = "../../../../../modules/eks_all_in_one"
  name              = local.name              # EKS cluster name
  region            = local.region            # AWS provider region
  aws_account_name  = local.aws_account_name  # AWS account name
  cidr              = local.vpc_cidr          # VPC CIDR

  cluster_version   = "1.28"                  # EKS cluster version

  # EKS Managed Private Node Group
  instance_types    = ["m6a.large"]           # EKS instance types
  ami_id            = "ami-0d9fe0469fe8439cb" # EKS AMI ID
  min_size          = 2                       # EKS node group min size
  max_size          = 10                      # EKS node group max size
  desired_size      = 2                       # EKS node group desired size

  # Add to argocd
  enroll_cluster_in_argocd = true
  argocd_server_address    = "argocd.prod.eticloud.io"
  argocd_instance_name     = "prod"
}