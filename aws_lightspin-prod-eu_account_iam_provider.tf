provider "vault" {
  address   = "https://keeper.cisco.com"
  namespace = "eticloud"
}


data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.account_name}/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"]
  region      = "us-east-2" # Must match the region where the EKS cluster and VPC are created.
  max_retries = 3
  default_tags {
    # These tags are required for security compliance.
    # For more information on Data Classification and Data Taxonomy, please talk to the SRE team.
    tags = {
      ApplicationName    = "Lightspin Production EU IAM Roles"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "Prod"
      ResourceOwner      = "ETI SRE"
    }
  }
}
