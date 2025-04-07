provider "vault" {
    alias = "eticcprod"
    address = "https://keeper.cisco.com"
    namespace = "eticloud/eticcprod"
}


terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-nonprod"
    key    = "terraform-state/eks/eu-west-1/cluster-eks-dev-2.tfstate"
    region = "us-east-2"
  }
}

data "vault_generic_secret" "aws_infra_credential" {
  provider = vault.eticcprod
  path = "secret/eticcprod/infra/prod/aws"
}
variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "eu-west-1" #Set the region for the resources to be created.
}

# Infra AWS Provider
provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
}

module "eks" {
  source           = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-eks.git?ref=1.5.0"
  cluster_name     = "eks-dev-2"
  cluster_version  = "1.21"
  vpc_name         = "sre-eu-west-1"
  cluster_os        = "AmazonLinux2"
  
  # Private Node group options
  # create_private_node_group = true #Defaults to true. Must be true for any of the below to be set by the module,
  private_node_group_desired_capacity = 4 #The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  private_node_group_min_capacity     = 2 #The minimum number of worker nodes.
  private_node_group_max_capacity     = 10 #The maximium number of worker nodes.
  private_node_group_instance_type    = ["m6a.large"] #The instance type for the worker nodes.
  # Public Node group options
  # create_public_node_group = true #Defaults to false. Must be true for any of the below to be set by the module,
  public_node_group_desired_capacity = 0 #The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  public_node_group_min_capacity     = 0 #The minimum number of worker nodes.
  public_node_group_max_capacity     = 10 #The maximium number of worker nodes.
  public_node_group_instance_type    = ["m6a.large"] #The instance type for the worker nodes.

  # aws-auth configmap
  manage_aws_auth_configmap = true
  aws_auth_roles            = [
    {
      rolearn  = "arn:aws:iam::626007623524:role/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::626007623524:role/eksdeveloper"
      username = "eksdeveloper"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::626007623524:role/sre-audit-ro"
      username = "sre-audit-ro"
      groups   = ["view"]
    },
  ]

  CSBDataClassification = "Cisco Restricted"
  CSBEnvironment        = "NonProd"
  CSBApplicationName    = "sre-eks"
  CSBResourceOwner      = "eti"
  CSBCiscoMailAlias     = "eti-sre@cisco.com"
  CSBDataTaxonomy       = "Cisco Operations Data"
}
