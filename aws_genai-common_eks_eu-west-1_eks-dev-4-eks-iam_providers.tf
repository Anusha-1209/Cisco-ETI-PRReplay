provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}


data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/genai-common/terraform_admin"
}

data "vault_generic_secret" "aws_infra_credential_eticloud_preprod" {
  path     = "secret/infra/aws/eticloud-preprod/terraform_admin"
}


locals {
  cluster_name = "eks-dev-4" # The name of the associated EKS cluster. Must be updated
  
}


provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "eu-west-1" # Must match the region where the EKS cluster and VPC are created.
  max_retries = 3
  default_tags {
    # These tags are required for security compliance. 
    # For more information on Data Classification and Data Taxonomy, please talk to the SRE team.
    tags = {
      ApplicationName    = "${local.cluster_name} IAM Roles"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}

# AWS account where the EKS cluster lives
provider "aws" {
  access_key = data.vault_generic_secret.aws_infra_credential_eticloud_preprod.data["AWS_ACCESS_KEY_ID"]
  secret_key = data.vault_generic_secret.aws_infra_credential_eticloud_preprod.data["AWS_SECRET_ACCESS_KEY"]
  region = "eu-west-1"
  alias  = "cluster-eks-dev-4"
}