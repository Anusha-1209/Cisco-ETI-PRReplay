terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws/vowel-genai-dev/us-east-2/eks/wandb-k8s-agent-1.tfstate"
    region = "us-east-2"
  }
}

locals {
  name             = "wandb-k8s-agent-1"
  region           = "us-east-2"
  aws_account_name = "vowel-genai-dev"
  vpc_cidr         = "10.0.0.0/16"
}

module "eks_all_in_one" {
  source                 = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"
  name                   = local.name             # EKS cluster name
  region                 = local.region           # AWS provider region
  aws_account_name       = local.aws_account_name # AWS account name
  cidr                   = local.vpc_cidr         # VPC CIDR
  cluster_version        = "1.28"                 # EKS cluster version
  bastion_instance_count = 1                      # Bastion instance count


  # EKS Managed Private Node Group
  instance_types          = ["m6a.xlarge"]
  ami_type                = "CISCO_HARDENED_AL2"
  skip_cisco_hardened_ami = false
  min_size                = 2
  max_size                = 6
  desired_size            = 2
  create_karpenter_irsa   = true
  create_alb_irsa         = false
  create_otel_irsa        = false
  additional_aws_auth_configmap_roles = [
    {
      rolearn  = "arn:aws:iam::961088030672:role/cluster-access",
      username = "cluster-access",
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::961088030672:role/devops",
      username = "devops",
      groups   = ["system:masters"]
    }
  ]
}
