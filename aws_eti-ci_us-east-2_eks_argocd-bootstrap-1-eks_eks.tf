terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/aws-eti-ci/eks/us-east-2/argocd-bootstrap-1-eks.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "us-east-2"
  default_tags {
    tags = {
      ApplicationName    = "argocd-bootstrap-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

provider "vault" {
  alias     = "eticloud_eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/eticcprod/infra/ci/aws"
  provider = vault.eticloud_eticcprod
}

data "aws_caller_identity" "current" {}

module "eks" {
  source          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-eks?ref=2.0.1"
  cluster_name    = "argocd-bootstrap-1"
  cluster_version = "1.26" # don't roll back!
  cluster_os      = "AmazonLinux2"
  vpc_name        = "argocd-bootstrap-1-vpc"
  # Private Node group options
  create_private_nodegroup            = true            # Defaults to true. Must be true for any of the below to be set by the module,
  private_node_group_desired_capacity = 3               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  private_node_group_min_capacity     = 3               # The minimum number of worker nodes.
  private_node_group_max_capacity     = 10              # The maximium number of worker nodes.
  private_node_group_instance_type    = ["m5a.2xlarge"] # The instance type for the worker nodes.

  # Public Node group options
  create_public_nodegroup            = false           # Defaults to false. Must be true for any of the below to be set by the module,
  public_node_group_desired_capacity = 0               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  public_node_group_min_capacity     = 0               # The minimum number of worker nodes.
  public_node_group_max_capacity     = 0               # The maximium number of worker nodes.
  public_node_group_instance_type    = ["m5a.xlarge"]  # The instance type for the worker nodes.

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
        rolearn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/devops",
        username = "devops",
        groups = ["system:masters"]
    }
   ]

   cluster_addons = {
     coredns = {
       addon_version     = "v1.9.3-eksbuild.3"
     }
     kube-proxy = {
       addon_version     = "v1.25.9-eksbuild.1"
     }
     vpc-cni = {
       addon_version     = "v1.12.6-eksbuild.2"
       configuration_values = jsonencode({
         env = {
           # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
           ENABLE_PREFIX_DELEGATION = "false"
           WARM_PREFIX_TARGET       = "0"
         }
       })
     }
     aws-ebs-csi-driver = {
       addon_version     = "v1.21.0-eksbuild.1"
     }
   }
}