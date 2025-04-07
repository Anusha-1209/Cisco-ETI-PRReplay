terraform {
  backend "s3" {
    # This is the name of the backend S3 bucket.
    bucket = "eticloud-tf-state-nonprod"
    # This is the path to the Terraform state file in the backend S3 bucket.
    key = "terraform-state/aws/eticloud/us-east-2/eks/comn-dev-use2-1.tfstate"
    # This is the region where the backend S3 bucket is located.
    region = "us-east-2" # DO NOT CHANGE.
  }
}

locals {
  name             = "comn-dev-use2-1"
  region           = "us-east-2"
  aws_account_name = "outshift-common-dev"
  account_id       = "471112537430"
}

module "eks_all_in_one" {
  source = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"

  name             = local.name               # EKS cluster name
  region           = local.region             # AWS provider region
  aws_account_name = local.aws_account_name   # AWS account name
  ami_id           = "ami-0d33fa832c75e40d0"  # AMI ID
  cidr             = "10.0.0.0/16"            # VPC CIDR
  cluster_version  = "1.29"                   # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m6a.2xlarge"] # EKS instance types
  min_size       = 3               # EKS node group min size
  max_size       = 3               # EKS node group max size
  desired_size   = 3               # EKS node group desired size

  # Karpenter
  create_karpenter_irsa = true # Create Karpenter IRSA

  additional_aws_auth_configmap_roles = [
    {
      rolearn  = "arn:aws:iam::${local.account_id}:user/terraform_admin",
      username = "terraform_admin",
      groups   = ["system:masters"]
    }
    , {
      rolearn  = "arn:aws:iam::${local.account_id}:role/devops",
      username = "devops",
      groups   = ["system:masters"]
    }
    , {
      rolearn  = "arn:aws:iam::${local.account_id}:role/cluster-access",
      username = "cluster-access",
      groups   = ["system:masters"]
    }
  ]
}
