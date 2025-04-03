provider "vault" {
  address   = "https://keeper.cisco.com" # DON'T CHANGE THIS VALUE
  namespace = "eticloud"                 # DON'T CHANGE THIS VALUE
  alias     = "eticloud"
}


data "vault_generic_secret" "aws_infra_credential" {
  path     = "secret/infra/aws/${local.account_name}/terraform_admin"
}

provider "aws" {
  access_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_ACCESS_KEY_ID"]     # DON'T CHANGE THIS VALUE
  secret_key  = data.vault_generic_secret.aws_infra_credential.data["AWS_SECRET_ACCESS_KEY"] # DON'T CHANGE THIS VALUE
  region      = "us-east-2" # Must match the region where the EKS cluster and VPC are created.
  max_retries = 3
  default_tags {
    # These tags are required for security compliance.
    # For more information on Data Classification and Data Taxonomy, please talk to the SRE team.
    tags = {
      ApplicationName    = "${local.account_name} Enhanced monitoring IAM Roles"
      CiscoMailAlias     = "eti-sre-admins@cisco.com"
      DataClassification = "Cisco Confidential"
      DataTaxonomy       = "Cisco Operations Data"
      Environment        = "NonProd"
      ResourceOwner      = "ETI SRE"
    }
  }
}
