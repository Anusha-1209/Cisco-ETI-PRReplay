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
    bucket = "eticloud-tf-state-nonprod"                       # We separate the different environments into different buckets. The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. The environment should match the CSBEnvironment below.
    key    = "terraform-state/eks/us-east-2/eks-obs-1.tfstate" #note the path here. It should match the patten terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                       #do not change
  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2" #Set the region for the resources to be created.
}

# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
  default_tags {
    tags = {
      ApplicationName    = "eks-obs-1"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      EnvironmentName    = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}
module "eks" {
  source       = "git::https://github.com/cisco-eti/sre-tf-module-aws-eks?ref=1.6.0"
  cluster_name = "eks-obs-1" #The name of the cluster.
  #cluster_version and cluster_os combine get the AMI for the worker nodes.
  cluster_version = "1.29"         #The version of the control plane.
  cluster_os      = "AmazonLinux2" #Current options are "Ubuntu20" and "AmazonLinux2".
  vpc_name        = "eks-obs-1"    #The name of the VPC where the cluster should live.
  # Private Node group options
  # create_private_node_group = true #Defaults to true. Must be true for any of the below to be set by the module,
  private_node_group_desired_capacity = 6               #The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  private_node_group_min_capacity     = 6               #The minimum number of worker nodes.
  private_node_group_max_capacity     = 10              #The maximium number of worker nodes.
  private_node_group_instance_type    = ["m5a.2xlarge"] #The instance type for the worker nodes.
  # Public Node group options
  # create_public_node_group = true #Defaults to false. Must be true for any of the below to be set by the module,
  public_node_group_desired_capacity = 0               #The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  public_node_group_min_capacity     = 2               #The minimum number of worker nodes.
  public_node_group_max_capacity     = 10              #The maximium number of worker nodes.
  public_node_group_instance_type    = ["m5a.2xlarge"] #The instance type for the worker nodes.

  # aws-auth configmap
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::626007623524:role/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::626007623524:role/sre-audit-ro"
      username = "sre-audit-ro"
      groups   = ["view"]
    },
  ]
}
