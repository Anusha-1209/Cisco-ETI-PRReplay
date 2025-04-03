module "eks_all_in_one" {
  source           = "git::https://github.com/cisco-eti/sre-tf-module-eks-allinone.git?ref=latest"
  name             = local.name             # EKS cluster name
  region           = local.region           # AWS provider region
  aws_account_name = local.eks_aws_account_name # AWS account name
  cidr             = "10.0.0.0/16"          # VPC CIDR
  private_subnet_bits = 2                  # Private subnet bits
  public_subnet_mask = 196
  intra_subnet_mask = 200
  cluster_version  = "1.30"                 # EKS cluster version

  # EKS Managed Private Node Group
  instance_types = ["m6a.2xlarge"] # EKS instance types
  min_size       = 5               # EKS node group min size
  max_size       = 15              # EKS node group max size
  desired_size   = 7               # EKS node group desired size

  # Karpenter
  create_karpenter_irsa = true # Create Karpenter IRSA
  create_otel_irsa = true
  create_alb_irsa = true
  create_ebs_csi_irsa = true 
  create_efs_csi_irsa = true 

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    # aws-ebs-csi-driver is not included to prevent installation
  }
}
module "eks-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::346196940956:role/devops",
      username = "devops",
      groups   = ["system:masters"]
    }
  ]

  # depends_on = [null_resource.wait_for_eks]
}