terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod"
    key    = "terraform-state/aws-eticloud/eks/eu-west-1/eks-gbear-prod-1.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region     = "eu-west-1"
  default_tags {
    tags = {
      ApplicationName    = "eks-gbear-prod-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "Prod"
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
  path     = "secret/eticcprod/infra/prod/aws"
  provider = vault.eticloud_eticcprod
}
module "eks" {
  source          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-eks?ref=1.9.0"
  cluster_name    = "eks-gbear-prod-1"
  cluster_version = "1.25" # don't roll back!
  cluster_os      = "AmazonLinux2"
  vpc_name        = "eks-gbear-prod-1-vpc"
  # Private Node group options
  create_private_nodegroup            = true            # Defaults to true. Must be true for any of the below to be set by the module,
  private_node_group_desired_capacity = 6               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  private_node_group_min_capacity     = 1               # The minimum number of worker nodes.
  private_node_group_max_capacity     = 10              # The maximium number of worker nodes.
  private_node_group_instance_type    = ["m5a.2xlarge"] # The instance type for the worker nodes.
  # Public Node group options
  create_public_nodegroup            = false           # Defaults to false. Must be true for any of the below to be set by the module,
  public_node_group_desired_capacity = 4               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  public_node_group_min_capacity     = 4               # The minimum number of worker nodes.
  public_node_group_max_capacity     = 8               # The maximium number of worker nodes.
  public_node_group_instance_type    = ["m5a.2xlarge"] # The instance type for the worker nodes.

  # aws-auth configmap
  manage_aws_auth_configmap = false # Set to false in SRE module
  # Add other roles for this particular cluster here. The module will add the default bootstrappers roles.
  # aws_auth_roles = [] # Leave empty. Only used during cluster creation
  # Any additional IAM roles to add. admin and sre-audit-ro are added by the sre module. To add the custom configmap, you must use the configmap module.
  aws_auth_additional_roles = [
    {
      rolearn  = "arn:aws:iam::626007623524:role/devops",
      username = "devops",
      groups   = ["view"]
    },
    {
      rolearn = "arn:aws:iam::626007623524:role/great-bear"
      username = "greatbear"
      groups = ["system:masters"]
    }
  ] 
  # cluster_addons = {} # check the variables for defaults. Do not change unless you know what you are doing.
}