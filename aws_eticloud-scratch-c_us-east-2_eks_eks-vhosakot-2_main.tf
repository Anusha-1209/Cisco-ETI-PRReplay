terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket  = "eticloud-tf-state-nonprod"                                                   # UPDATE ME.
    # This is the path to the Terraform state file in the backend S3 bucket.
    key     = "terraform-state/aws/eticloud-scratch-c/us-east-2/eks/eks-vhosakot-2.tfstate" # UPDATE ME.
    # This is the region where the backend S3 bucket is located.
    region  = "us-east-2"                                                                   # DO NOT CHANGE.

  }
}

locals {
  name              = "eks-vhosakot-2"
  region            = "us-east-2"
  aws_account_name  = "eticloud-scratch-c"
  vpc_cidr          = "10.0.0.0/16"
}

module "eks_all_in_one" {
  source                  = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest" # Based on v0.0.10
  name                    = local.name              # EKS cluster name
  region                  = local.region            # AWS provider region
  aws_account_name        = local.aws_account_name  # AWS account name
  cidr                    = local.vpc_cidr          # VPC CIDR
  cluster_version         = "1.28"                  # EKS cluster version
  bastion_instance_count  = 0


  # EKS Managed Private Node Group
  instance_types          = ["m6a.large"]           # EKS instance types
  ami_id                  = "ami-07dfcba6727039752" # EKS AMI ID
  min_size                = 2                       # EKS node group min size
  max_size                = 5                       # EKS node group max size
  desired_size            = 2                       # EKS node group desired size
  create_karpenter_irsa   = false
  create_alb_irsa         = false
  create_otel_irsa        = false
  additional_aws_auth_configmap_roles = [
      {
        rolearn  = "arn:aws:iam::244624147909:role/cluster-access",
        username = "cluster-access",
        groups   = ["system:masters"]
      }
  ]
}