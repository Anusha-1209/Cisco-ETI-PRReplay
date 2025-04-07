terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-apisec-prod/eks/eu-central-1/apisec-prod-eu-1-eks.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "eu-central-1"
  default_tags {
    tags = {
      ApplicationName    = "apisec-prod-eu-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/apisec-prod/terraform_admin"
  provider = vault.eticloud
}

data "aws_caller_identity" "current" {}
variable "cluster_name" {
  type        = string
  default = "apisec-prod-eu-1"
}
module "eks" {
  source          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-eks?ref=2.0.3"
  cluster_name    = "apisec-prod-eu-1"
  cluster_version = "1.28" # don't roll back!
  cluster_os      = "AmazonLinux2"
  vpc_name        = "apisec-prod-eu-1-vpc"

   # aws-auth configmap
  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false # Set to false in SRE module 
  
  # Private Node group options
  create_private_nodegroup            = true            # Defaults to true. Must be true for any of the below to be set by the module,
  private_node_group_desired_capacity = 6               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  private_node_group_min_capacity     = 5               # The minimum number of worker nodes.
  private_node_group_max_capacity     = 10              # The maximium number of worker nodes.
  private_node_group_instance_type    = ["m5a.2xlarge"] # The instance type for the worker nodes.

  # Public Node group options
  create_public_nodegroup            = false           # Defaults to false. Must be true for any of the below to be set by the module,
  public_node_group_desired_capacity = 0               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  public_node_group_min_capacity     = 2               # The minimum number of worker nodes.
  public_node_group_max_capacity     = 10              # The maximium number of worker nodes.
  public_node_group_instance_type    = ["m5a.2xlarge"] # The instance type for the worker nodes.

  aws_auth_additional_roles = [    
        {
            rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/devops",
            username = "devops",
            groups = ["system:masters"]
        },
        {
            rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterNodeRole-${var.cluster_name}",
            username = "system:node:{{EC2PrivateDNSName}}",
            groups = ["system:bootstrappers","system:nodes"]        
        }
    ]
  
  cluster_addons = {
    coredns = {
      addon_version     = "v1.10.1-eksbuild.7"
    }
    kube-proxy = {
      addon_version     = "v1.27.8-eksbuild.4"
    }
    vpc-cni = {
      addon_version     = "v1.16.4-eksbuild.2"
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "false"
          WARM_PREFIX_TARGET       = "2"
        }
      })
    }
    aws-ebs-csi-driver = {
      addon_version     = "v1.28.0-eksbuild.1"
    }
    aws-efs-csi-driver = {
      addon_version     = "v1.7.5-eksbuild.2"
    }
  }
}

