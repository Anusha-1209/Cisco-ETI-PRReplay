provider "vault" {
  alias     = "eticcprod"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud/eticcprod"
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path     = "secret/eticcprod/infra/prod/aws"
}

terraform {
  backend "s3" {
    bucket  = "eticloud-tf-state-prod"                           # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key     = "terraform-state/eks/us-east-2/eks-prod-4.tfstate" #note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region  = "us-east-2"                                        #do not change
  }
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-west-2" #Set the region for the resources to be created.
}

# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
  default_tags {
    tags = {
      DataClassification = "Cisco Restricted"
      Environment        = "Prod"
      ApplicationName    = "eks-prod-4-eks"
      ResourceOwner      = "eti sre"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataTaxonomy       = "Cisco Operations Data"
    }
  }
}
module "eks" {
  source       = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-eks?ref=1.9.0"
  cluster_name = "eks-prod-4" #The name of the cluster.
  #cluster_version and cluster_os combine get the AMI for the worker nodes.
  cluster_version = "1.26"           #The version of the control plane.
  cluster_os      = "AmazonLinux2"   #Current options are "Ubuntu20" and "AmazonLinux2".
  vpc_name        = "eks-prod-4-vpc" #The name of the VPC where the cluster should live.
  # Private Node group options
  # create_private_node_group = true #Defaults to true. Must be true for any of the below to be set by the module,
  private_node_group_desired_capacity = 9               #The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  private_node_group_min_capacity     = 7               #The minimum number of worker nodes.
  private_node_group_max_capacity     = 11              #The maximium number of worker nodes.
  private_node_group_instance_type    = ["m6a.2xlarge"] #The instance type for the worker nodes.
  # Public Node group options
  create_public_nodegroup            = false         #Defaults to false. Must be true for any of the below to be set by the module,
  public_node_group_desired_capacity = 4             #The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  public_node_group_min_capacity     = 2             #The minimum number of worker nodes.
  public_node_group_max_capacity     = 6             #The maximium number of worker nodes.
  public_node_group_instance_type    = ["m6a.large"] #The instance type for the worker nodes.

  # aws-auth configmap
  # manage_aws_auth_configmap = true # Set to false in SRE module
  # Add other roles for this particular cluster here. The module will add the default bootstrappers roles.
  # aws_auth_roles = [] # Leave empty. Only used during cluster creation
  # Any additional IAM roles to add. admin and sre-audit-ro are added by the sre module. To add the custom configmap, you must use the configmap module.
  aws_auth_additional_roles = [
    {
      rolearn  = "arn:aws:iam::626007623524:role/devops",
      username = "devops",
      groups   = ["view"]
    }
  ] 
  # cluster_addons = {} # check the variables for defaults. Do not change unless you know what you are doing.
}
