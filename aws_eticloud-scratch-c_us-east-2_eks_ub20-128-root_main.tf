# This file was created by Outshift Platform Self-Service automation.
module "eks_all_in_one" {
  source                 = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"
  name                   = local.name             # EKS cluster name
  region                 = local.region           # AWS provider region
  aws_account_name       = local.aws_account_name # AWS account name
  cidr                   = local.vpc_cidr         # VPC CIDR
  cluster_version        = "1.28"   # EKS cluster version
  bastion_instance_count = 1                      # Bastion instance count


  # EKS Managed Private Node Group
  instance_types          = ["m6a.2xlarge"]
  ami_type                = "CISCO_HARDENED_UBUNTU20"
  skip_cisco_hardened_ami = "false"
  min_size                = "1"
  max_size                = "6"
  desired_size            = "1"
  create_karpenter_irsa   = "true"
  create_alb_irsa         = "true"
  create_otel_irsa        = "true"
}
