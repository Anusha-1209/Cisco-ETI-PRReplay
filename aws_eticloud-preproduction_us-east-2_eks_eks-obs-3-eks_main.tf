module "eks" {
  source          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-eks?ref=1.6.2-updates"
  cluster_name    = "eks-obs-3"
  cluster_version = "1.27" # don't roll back!
  cluster_os      = "AmazonLinux2"
  vpc_name        = "eks-obs-3-vpc"
  # Private Node group options
  create_private_nodegroup            = true            # Defaults to true. Must be true for any of the below to be set by the module,
  private_node_group_desired_capacity = 6               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  private_node_group_min_capacity     = 6               # The minimum number of worker nodes.
  private_node_group_max_capacity     = 10              # The maximium number of worker nodes.
  private_node_group_instance_type    = ["m5a.2xlarge"] # The instance type for the worker nodes.
  # Public Node group options
  create_public_nodegroup            = false           # Defaults to false. Must be true for any of the below to be set by the module,
  public_node_group_desired_capacity = 0               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  public_node_group_min_capacity     = 2               # The minimum number of worker nodes.
  public_node_group_max_capacity     = 10              # The maximium number of worker nodes.
  public_node_group_instance_type    = ["m5a.2xlarge"] # The instance type for the worker nodes.

  # aws-auth configmap
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::792074902331:role/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::792074902331:role/developer-access"
      username = "developer-access"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::792074902331:role/read-only-access"
      username = "read-only-access"
      groups   = ["view"]
    },
  ]
  cluster_addons = {
    coredns = {
      addon_version     = "v1.10.1-eksbuild.4" 
    }
    kube-proxy = {
      addon_version     = "v1.27.6-eksbuild.2" 
    }
    vpc-cni = {
      addon_version     = "v1.15.0-eksbuild.2" 
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "false"
          WARM_PREFIX_TARGET       = "0"
        }
      })
    }
    aws-ebs-csi-driver = {
      addon_version     = "v1.23.0-eksbuild.1" 
    }
  }
  providers = {
    vault = vault.eticloud_eticcprod
  }

}
