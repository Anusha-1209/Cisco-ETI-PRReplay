terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/cnapp-staging/eu-central-1/eks/cnapp-staging-euc1-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.
  }
}

locals {
  name             = "cnapp-staging-euc1-1"
  region           = "eu-central-1"
  aws_account_name = "cnapp-staging"
}

data "aws_caller_identity" "current" {}

module "eks_all_in_one" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"

  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.0.0.0/16"          # VPC CIDR
  cluster_version  = "1.28"                 # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m6a.2xlarge"] # EKS instance types
  min_size       = 1               # EKS node group min size
  max_size       = 3               # EKS node group max size
  desired_size   = 3               # EKS node group desired size

  # Karpenter
  create_karpenter_irsa = true # Create Karpenter IRSA
  additional_aws_auth_configmap_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/staging-eu-eks-role",
      username = "devops",
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterControllerRole-cnapp-staging-euc1-1",
      username = "system:node:{{EC2PrivateDNSName}}",
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]
}
