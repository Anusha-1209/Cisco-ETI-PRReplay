terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key = "terraform-state/aws/lightspin-prod/us-east-1/eks/recon-prod-use2-1.tfstate"
    region = "us-east-2"
  }
}

data "aws_caller_identity" "current" {}

locals {
  name             = "recon-prod-use1-1"
  region           = "us-east-1"
  aws_account_name = "lightspin-prod"
  account_id = data.aws_caller_identity.current.account_id
}

module "eks_all_in_one" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"
  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.aws_account_name # AWS account name
  cidr             = "10.1.0.0/16"          # VPC CIDR
  cluster_version  = "1.28"                 # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m6a.2xlarge"] # EKS instance types
  min_size       = 3               # EKS node group min size
  max_size       = 5              # EKS node group max size
  desired_size   = 3               # EKS node group desired size

  create_karpenter_irsa = true # Create Karpenter IRSA
  create_alb_irsa = true
  create_otel_irsa = true
  additional_aws_auth_configmap_roles = [
      {
        rolearn  = "arn:aws:iam::${local.account_id}:role/devops",
        username = "devops",
        groups   = ["system:masters"]
      }
  ]
}
