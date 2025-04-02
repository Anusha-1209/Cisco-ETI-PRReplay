module "eks" {
  source          = "git::https://github.com/cisco-eti/sre-tf-module-aws-eks?ref=2.0.1"
  cluster_name    = "dragonfly-prod-1"
  cluster_version = "1.27" # don't roll back!
  cluster_os      = "AmazonLinux2"
  vpc_name        = "dragonfly-compute-prod-1-vpc"

  # Private Node group options
  create_private_nodegroup            = true            # Defaults to true. Must be true for any of the below to be set by the module,
  private_node_group_desired_capacity = 6               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  private_node_group_min_capacity     = 5               # The minimum number of worker nodes.
  private_node_group_max_capacity     = 10              # The maximium number of worker nodes.
  private_node_group_instance_type    = ["m5a.2xlarge"] # The instance type for the worker nodes.

  # Public Node group options
  create_public_nodegroup            = false          # Defaults to false. Must be true for any of the below to be set by the module,
  public_node_group_desired_capacity = 0              # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  public_node_group_min_capacity     = 0              # The minimum number of worker nodes.
  public_node_group_max_capacity     = 0              # The maximium number of worker nodes.
  public_node_group_instance_type    = ["m5a.xlarge"] # The instance type for the worker nodes.

  # aws-auth configmap
  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false # Set to false in SRE module

  aws_auth_additional_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/devops",
      username = "devops",
      groups   = ["system:masters"]
    },
    { # Role for karpenter
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterNodeRole-dragonfly-prod-1",
      username = "system:node:{{EC2PrivateDNSName}}",
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  cluster_addons = {
    coredns = {
      addon_version = "v1.10.1-eksbuild.4"
    }
    kube-proxy = {
      addon_version = "v1.27.6-eksbuild.2"
    }
    vpc-cni = {
      addon_version = "v1.15.1-eksbuild.1"
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "false"
          WARM_PREFIX_TARGET       = "0"
        }
      })
    }
    aws-ebs-csi-driver = {
      addon_version = "v1.23.1-eksbuild.1"
    }
  }

  providers = {
    vault = vault.eticloud
  }
}
