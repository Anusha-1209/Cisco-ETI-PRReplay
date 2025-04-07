
# This provider allows access to the eticloud/eticcprod namespace in Keeper. Do not modify it without discussing with the SRE team.
provider "vault" {
  alias     = "eticloud"
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}

# Change `path = "secret/eticcprod/infra/<account_name>/aws" to specify the account in which the resources will be created. 
# Must match the account in which the VPC was created.
data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/eti-ci/terraform_admin"
  provider = vault.eticloud
}

terraform {
  backend "s3" {
    bucket = "eticloud-tf-state-prod" # We separate the different environments into different buckets.
    # The buckets are eticloud-tf-state-sandbox, eticloud-tf-state-nonprod, eticloud-tf-state-prod. 
    # <bucket_name> in eticloud-tf-state-<bucket_name> should match the Environment tag below.
    key    = "terraform-state/aws-eti-ci/vpc/us-east-2/eks-gitops-genai-1-eks.tfstate" # The path should match the pattern terraform_state/<service>/<region>/<name>.tfstate
    region = "us-east-2"                                        # Do not change.
    # profile = "eticloud" # If you are doing developing Terraform, you can specify a local AWS profile to use for accessing the statefile ONLY. 
    # A CLI login to Keeper is also required.
  }
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = var.AWS_INFRA_REGION
  max_retries = 3
  default_tags {
    # These tags are required for security compliance. 
    # For more information on Data Classification and Data Taxonomy, please talk to the SRE team.
    tags = {
      ApplicationName    = "eks-gitops-genai-1-eks"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Restricted"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "Outshift SRE"
    }
  }
}

variable "AWS_INFRA_REGION" {
  description = "AWS Region"
  default     = "us-east-2" # The region in which the EKS cluster will be created. 
  # Must match the region in which the VPC was created.
}

module "eks" {
  source          = "git::https://wwwin-github.cisco.com/eti/sre-tf-module-aws-eks?ref=2.0.4"
  cluster_name    = "eks-gitops-genai-1" # The name of the cluster.
  cluster_version = "1.27"       # The version of kubernetes for the control plane.
  # cluster_version and cluster_os combine get the hardened AMI for the worker nodes.
  cluster_os = "AmazonLinux2"   # The current supported options are "Ubuntu20" and "AmazonLinux2".
  vpc_name   = "eks-gitops-genai-1-vpc" # The name of the VPC in which the cluster should be created.
  # Private node group options
  # create_private_node_group = true # Defaults to true. Must be true for any of the below to be set by the module,
  private_node_group_desired_capacity = 6               # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  private_node_group_min_capacity     = 5               # The minimum number of worker nodes.
  private_node_group_max_capacity     = 10              # The maximium number of worker nodes.
  private_node_group_instance_type    = ["m5d.2xlarge"] # The instance type for the worker nodes.
  # Public Node group options
  create_public_nodegroup            = false         # Defaults to false. Must be true for any of the below to be set by the module,
  public_node_group_desired_capacity = 4             # The desired number of worker nodes. Once this is set, the number of desired instances must be manually modified.
  public_node_group_min_capacity     = 2             # The minimum number of worker nodes.
  public_node_group_max_capacity     = 6             # The maximium number of worker nodes.
  public_node_group_instance_type    = ["m5d.large"] # The instance type for the worker nodes.

  # aws-auth configmap creation an management
  # A default aws-auth configmap is created that only allows cluster access to the IAM principal that created the cluster.
  # Because we create and manage our own aws-auth configmap outside this module, we set both these parameters to `false`.
  # After the EKS cluster is created, run the `eks-cm` project to apply our customizations and allow access.

  # create_aws_auth_configmap = false # Defaults to false in the SRE module.
  # manage_aws_auth_configmap = false # Defaults to false in SRE module.
  # Add other roles for this particular cluster here. The upstream module will add the default bootstrappers roles.
  # aws_auth_roles = [] # Leave empty. Only used during cluster creation

  # Add other IAM roles for this particular cluster here. 
  # The upstream module will add the default bootstrappers roles.  
  # When modularizing, aws_auth_additional_roles should be a list of strings; for_each; to create a list of maps.
  aws_auth_additional_roles = [
    {
      rolearn  = "arn:aws:iam::009736724745:role/devops",
      username = "devops",
      groups   = ["view"]
    }
  ] # any additional IAM roles to add. admin and sre-audit-ro are added by the sre module.
  # cluster_addons = {}     # This module insalls the latest versions of the cluster addons.
  # Do not change unless you know what you are doing.
}